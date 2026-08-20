from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "data" / "UserBehavior.csv"
OUTPUT = ROOT / "data" / "powerbi_sample.csv"
COLUMNS = ["user_id", "item_id", "category_id", "behavior_type", "timestamp"]


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"找不到数据文件: {SOURCE}")

    sample = pd.read_csv(
        SOURCE,
        names=COLUMNS,
        nrows=1_000_000,
    )
    sample.to_csv(OUTPUT, index=False, encoding="utf-8-sig")
    print(f"已生成 Power BI 样本: {OUTPUT}")
    print(f"行数: {len(sample):,}")


if __name__ == "__main__":
    main()