
import argparse
from pathlib import Path

import pandas as pd

from common import configure_plot, load_csv, save_csv, save_json, validate_orders


def load_orders(path):
    cols = ["order_id", "region", "sub_category", "is_returned"]
    df = load_csv(path, cols, ["is_returned"])
    if not df["is_returned"].isin([0, 1]).all():
        raise ValueError("is_returned 只能为 0 或 1")
    validate_orders(df)
    if df.groupby("order_id")["is_returned"].nunique().gt(1).any():
        raise ValueError("同一订单的 is_returned 不一致，请先修正导出逻辑")
    return df


def summarize(df, keys):
    # 同一订单多个商品行只计一次；跨子类别订单可在不同子类别中各出现一次。
    orders = df[keys + ["order_id", "is_returned"]].drop_duplicates()
    out = orders.groupby(keys, dropna=False).agg(
        total_orders=("order_id", "nunique"), returned_orders=("is_returned", "sum"),
    ).reset_index()
    out["return_rate"] = out["returned_orders"] / out["total_orders"]
    return out


def run(input_path, output_dir):
    df = load_orders(input_path)
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    orders = df[["order_id", "is_returned"]].drop_duplicates()
    total = len(orders)
    returned = int(orders["is_returned"].sum())
    baseline = returned / total
    regions = summarize(df, ["region"]).sort_values("return_rate", ascending=False)
    regions["difference_vs_overall_pp"] = (regions["return_rate"] - baseline) * 100
    save_csv(regions, out / "region_returns.csv")
    save_csv(summarize(df, ["region", "sub_category"]), out / "region_subcategory_returns.csv")
    west = df.loc[df["region"].str.casefold().eq("west")]
    save_csv(summarize(west, ["sub_category"]), out / "west_subcategory_returns.csv")
    save_json({
        "total_orders": total, "returned_orders": returned, "return_rate": baseline,
        "definition": "去重退货订单数 / 去重订单数；return_rate 为 0~1 比例",
        "limitation": "订单级退货标记，不代表该订单中每条商品明细均已退货；非净退款金额",
    }, out / "overall_returns.json")
    plt = configure_plot()
    shown = regions.sort_values("return_rate")
    fig, ax = plt.subplots(figsize=(9, max(4, len(shown) * 0.6)))
    bars = ax.barh(shown["region"], shown["return_rate"] * 100, color="#356f9f")
    ax.bar_label(bars, labels=[f"{r:.2%} (n={n:,})" for r, n in zip(shown["return_rate"], shown["total_orders"])], padding=4)
    ax.axvline(baseline * 100, color="#d97732", linestyle="--", label=f"Overall {baseline:.2%}")
    ax.set(title="Returned-order rate by region", xlabel="Returned orders / all orders (%)")
    ax.set_xlim(0, max(1, float(shown["return_rate"].max()) * 100) * 1.4)
    ax.legend()
    fig.tight_layout()
    fig.savefig(out / "region_return_rate.png", dpi=160)
    plt.close(fig)
    return regions


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", type=Path, default=Path(__file__).resolve().parents[1] / "outputs" / "returns")
    args = parser.parse_args()
    run(args.input, args.output)
    print(f"区域退货分析已输出至：{args.output}")
