# Exploit Prediction Scoring System (EPSS)

- Ingest EPSS scores from [`empiricalsec/epss_scores`](https://github.com/empiricalsec/epss_scores) while partitioning by date
- EPSS scores are stored in Parquet format with Snappy compression
- Memory usage is capped at 8 GB
