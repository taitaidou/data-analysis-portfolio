"""仅使用内存构造的测试订单；测试数据不是项目业务结果。"""

import tempfile
import unittest
from pathlib import Path

import pandas as pd

import discount_analysis as discount
import regional_returns_analysis as returns


def fixture():
    return pd.DataFrame([
        ["001", "West", "Furniture", "Tables", 100, 10, 0, 1],
        ["001", "West", "Furniture", "Tables", 50, -5, 0.2, 1],
        ["002", "West", "Furniture", "Chairs", 150, 30, 0.2, 0],
        ["002", "West", "Furniture", "Tables", 100, -20, 0.4, 0],
        ["003", "East", "Technology", "Phones", 100, 40, 0.5, 1],
    ], columns=["order_id", "region", "category", "sub_category", "sales", "profit", "discount", "is_returned"])


class AnalysisTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.path = self.root / "orders.csv"
        fixture().to_csv(self.path, index=False)

    def tearDown(self):
        self.tmp.cleanup()

    def test_discount_boundaries_and_weighted_margin(self):
        df = discount.load_orders(self.path)
        self.assertEqual(df["discount_level"].astype(str).tolist(), [
            "No Discount", "Low Discount", "Low Discount", "Medium Discount", "High Discount",
        ])
        grouped = discount.summarize(df, ["discount_level"]).set_index("discount_level")
        # low 组总利润25、总销售200，不能简单平均两行利润率。
        self.assertAlmostEqual(grouped.loc["Low Discount", "profit_margin"], 0.125)
        self.assertEqual(grouped.loc["Low Discount", "unique_orders"], 2)

    def test_returns_use_unique_orders(self):
        df = returns.load_orders(self.path)
        self.assertEqual(df["order_id"].iloc[0], "001")
        regions = returns.summarize(df, ["region"]).set_index("region")
        self.assertEqual(regions.loc["West", "total_orders"], 2)
        self.assertEqual(regions.loc["West", "returned_orders"], 1)
        self.assertAlmostEqual(regions.loc["West", "return_rate"], 0.5)

    def test_invalid_discount_is_rejected(self):
        df = fixture()
        df.loc[0, "discount"] = 20
        df.to_csv(self.path, index=False)
        with self.assertRaisesRegex(ValueError, "discount"):
            discount.load_orders(self.path)

    def test_inconsistent_order_flags_are_rejected(self):
        df = fixture()
        df.loc[0, "is_returned"] = 0
        df.to_csv(self.path, index=False)
        with self.assertRaisesRegex(ValueError, "is_returned"):
            returns.load_orders(self.path)

    def test_cross_region_orders_are_rejected(self):
        df = fixture()
        df.loc[0, "region"] = "East"
        df.to_csv(self.path, index=False)
        with self.assertRaisesRegex(ValueError, "多个 region"):
            returns.load_orders(self.path)

    def test_missing_columns_are_rejected(self):
        fixture().drop(columns="sales").to_csv(self.path, index=False)
        with self.assertRaisesRegex(ValueError, "缺少列"):
            discount.load_orders(self.path)

    def test_constant_discount_has_no_correlation_claim(self):
        df = discount.load_orders(self.path)
        df["discount"] = 0
        self.assertIsNone(discount.correlation(df)["pearson_discount_vs_line_profit_margin"])

    def test_empty_optional_tables_groups(self):
        df = discount.load_orders(self.path)
        empty = discount.summarize(df.iloc[:0], ["region", "discount_level"])
        self.assertTrue(empty.empty)
        self.assertIn("profit_margin", empty.columns)

    def test_full_output_generation(self):
        discount.run(self.path, self.root / "discount")
        returns.run(self.path, self.root / "returns")
        self.assertTrue((self.root / "discount" / "discount_margin_scatter.png").stat().st_size > 0)
        self.assertTrue((self.root / "returns" / "region_return_rate.png").stat().st_size > 0)
        import json
        overall = json.loads((self.root / "returns" / "overall_returns.json").read_text(encoding="utf-8"))
        self.assertEqual(overall["total_orders"], 3)
        self.assertEqual(overall["returned_orders"], 2)
        self.assertAlmostEqual(overall["return_rate"], 2 / 3)


if __name__ == "__main__":
    unittest.main()
