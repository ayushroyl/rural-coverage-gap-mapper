# Data Directory

This directory holds geospatial and demographic datasets used by the application.

## Structure

```
data/
├── raw/          # Unmodified source files downloaded from public datasets
├── processed/    # Cleaned and transformed data ready for analysis
└── simulated/    # Synthetically generated data for MVP development & testing
```

## Public Data Sources

| Dataset | Source | Format | Notes |
|---------|--------|--------|-------|
| District boundaries | [Datameet India Maps](https://github.com/datameet/maps) | GeoJSON/SHP | Karnataka district polygons |
| Village locations | [Census of India](https://censusindia.gov.in/) | CSV/SHP | Village-level lat/lon |
| Population data | [Census 2011](https://censusindia.gov.in/) | CSV | District/taluk/village level |
| Mobile tower locations | [TRAI](https://trai.gov.in/) / OpenCelliD | CSV | Active BTS tower positions |
| Road network | [OpenStreetMap](https://www.openstreetmap.org/) | PBF/GeoJSON | Via Overpass API or Geofabrik |

## Simulated Data

Simulated datasets are generated programmatically for MVP development when
real data is unavailable or restricted. Scripts for simulation will be placed
in `backend/app/services/` or a dedicated `scripts/` directory.

## ⚠️ Important

- **Raw data files are NOT committed to version control** (see `.gitignore`).
- Large files should be managed with [DVC](https://dvc.org/) or stored in object storage.
- Document the download source and version for every raw dataset in a `data/raw/SOURCES.md` file.

