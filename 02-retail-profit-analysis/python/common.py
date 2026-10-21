
from pathlib import Path
import json

import numpy as np
import pandas as pd


def load_csv(path, required, numeric=()):
    # 订单 ID 强制按文本读取，保留前导零；不自动将 NA 等文本转成空值。
    df = pd.read_csv(path, encoding="utf-8-sig", dtype=str, keep_default_na=False)
    df.columns = df.columns.str.strip()
    if df.columns.duplicated().any():
        raise ValueError("存在重复列名")
    missing = sorted(set(required) - set(df.columns))
    if missing:
        raise ValueError(f"缺少列：{missing}")
    if df.empty:
        raise ValueError("输入表没有数据")
    for col in required:
        df[col] = df[col].str.strip()
        if df[col].eq("").any():
            raise ValueError(f"{col} 含空值，请先核对原始数据")
    for col in numeric:
        df[col] = pd.to_numeric(df[col], errors="raise")
        if not np.isfinite(df[col].to_numpy(dtype=float)).all():
            raise ValueError(f"{col} 含非有限数值")
    return df


def validate_orders(df):
    """本项目要求一个订单属于一个区域；不要求订单只含一个子类别。"""
    if df.groupby("order_id")["region"].nunique().gt(1).any():
        raise ValueError("同一 order_id 对应多个 region，不能直接汇总区域订单率")


def save_csv(df, path):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    # 比率和金额保留计算精度；显示时再控制小数位。
    df.to_csv(path, index=False, encoding="utf-8-sig", float_format="%.10g")


def save_json(value, path):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(
        json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
        encoding="utf-8",
    )


def configure_plot():
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib import font_manager
    available = {f.name for f in font_manager.fontManager.ttflist}
    for name in ["Microsoft YaHei", "SimHei", "Noto Sans CJK SC"]:
        if name in available:
            plt.rcParams["font.family"] = name
            break
    plt.rcParams["axes.unicode_minus"] = False
    return plt
