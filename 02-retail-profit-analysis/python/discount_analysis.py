"""折扣与利润描述性分析。输入为订单明细，不能使用现有月度/品类汇总表。"""

import argparse
from pathlib import Path

import numpy as np
import pandas as pd

from common import configure_plot, load_csv, save_csv, save_json, validate_orders


DISCOUNT_LEVELS = ["No Discount", "Low Discount", "Medium Discount", "High Discount"]


def load_orders(path):
    cols = ["order_id", "region", "category", "sub_category", "sales", "profit", "discount"]
    df = load_csv(path, cols, ["sales", "profit", "discount"])
    if df["sales"].le(0).any():
        raise ValueError("sales 必须大于 0；零/负销售额需单独核对，不能静默删除")
    if not df["discount"].between(0, 1).all():
        raise ValueError("discount 必须是 0~1 的折扣比例，例如 0.2；不要输入 20")
    validate_orders(df)
    df["discount_level"] = pd.Categorical(
        np.select(
            [df["discount"].eq(0), df["discount"].le(0.2), df["discount"].le(0.4)],
            DISCOUNT_LEVELS[:3], default=DISCOUNT_LEVELS[3],
        ), categories=DISCOUNT_LEVELS, ordered=True,
    )
    df["line_profit_margin"] = df["profit"] / df["sales"]
    df["is_loss"] = df["profit"].lt(0).astype(int)
    return df


def summarize(df, keys):
    out = df.groupby(keys, observed=True, dropna=False).agg(
        line_count=("order_id", "size"),
        unique_orders=("order_id", "nunique"),
        total_sales=("sales", "sum"), total_profit=("profit", "sum"),
        avg_discount=("discount", "mean"), loss_lines=("is_loss", "sum"),
    ).reset_index()
    out["profit_margin"] = out["total_profit"] / out["total_sales"]
    out["loss_line_rate"] = out["loss_lines"] / out["line_count"]
    return out


def correlation(df):
    # 按订单明细行计算，不将折扣组均值之间的相关性冒充明细相关性。
    enough = len(df) >= 3 and df["discount"].nunique() > 1 and df["line_profit_margin"].nunique() > 1
    return {
        "n_lines": int(len(df)),
        "pearson_discount_vs_line_profit_margin": (
            float(df["discount"].corr(df["line_profit_margin"])) if enough else None
        ),
        "reason_if_null": None if enough else "至少需要三行且折扣、明细利润率均有变化",
        "unit": "discount 和利润率均为小数比例",
        "interpretation": "描述性相关，非因果证据；未控制品类、地区、订单构成等混杂因素",
    }


def run(input_path, output_dir):
    df = load_orders(input_path)
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    overall = summarize(df, ["discount_level"])
    save_csv(overall, out / "discount_summary.csv")
    save_csv(summarize(df, ["category", "discount_level"]), out / "category_discount_summary.csv")
    save_csv(summarize(df, ["sub_category", "discount_level"]), out / "subcategory_discount_summary.csv")
    tables = df.loc[df["sub_category"].str.casefold().eq("tables")]
    save_csv(summarize(tables, ["region", "discount_level"]), out / "tables_region_discount_summary.csv")
    save_json(correlation(df), out / "discount_correlation.json")
    plt = configure_plot()
    fig, ax = plt.subplots(figsize=(9, 5))
    colors = ["#d97732" if x < 0 else "#356f9f" for x in overall["profit_margin"]]
    ax.bar(overall["discount_level"].astype(str), overall["profit_margin"] * 100, color=colors)
    ax.axhline(0, color="#777777", linewidth=0.8)
    ax.set(title="Profit margin by discount level", ylabel="Profit margin (%)")
    fig.tight_layout()
    fig.savefig(out / "discount_profit_margin.png", dpi=160)
    plt.close(fig)
    # 图形最多抽取 5,000 行；上面的相关系数仍使用全部有效明细。
    shown = df.sample(min(5000, len(df)), random_state=42)
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.scatter(shown["discount"] * 100, shown["line_profit_margin"] * 100, s=10, alpha=0.2)
    ax.set(title="Discount vs line profit margin (descriptive)", xlabel="Discount (%)", ylabel="Line profit margin (%)")
    fig.tight_layout()
    fig.savefig(out / "discount_margin_scatter.png", dpi=160)
    plt.close(fig)
    return overall


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", type=Path, default=Path(__file__).resolve().parents[1] / "outputs" / "discount")
    args = parser.parse_args()
    run(args.input, args.output)
    print(f"折扣分析已输出至：{args.output}")
