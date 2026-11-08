# Rural Coverage Gap Mapper · SW-27

> A geospatial web application that identifies underserved rural areas, analyses affected populations, and recommends optimal locations for new mobile towers — starting with Karnataka, India.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Repository Structure](#repository-structure)
5. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Backend Setup](#backend-setup)
   - [Frontend Setup](#frontend-setup)
   - [Database Setup](#database-setup)
6. [Running the Application](#running-the-application)
7. [API Reference](#api-reference)
8. [Roadmap](#roadmap)
9. [Contributing](#contributing)

---

## Project Overview

Millions of people in rural India lack reliable mobile connectivity. This platform helps telecom planners and policymakers:

- **Visualise** existing mobile tower coverage on an interactive map.
- **Identify** coverage gaps — areas with no or poor signal.
- **Analyse** affected population using census and demographic data.
- **Recommend** the most impactful locations for new towers using a _Greedy Maximum Coverage Algorithm_.

### MVP Scope

| Dimension | Detail |
|-----------|--------|
| Geography | **Tumkur district, Karnataka** (expandable to all 31 districts) |
| Data | Public datasets (Census 2011, TRAI, OpenCelliD) + simulated data |
| Algorithm | Greedy Maximum Coverage (future: ILP, Genetic Algorithm) |
| Users | Telecom planners, district administrators, NGO researchers |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Browser                              │
│          React + Vite + Tailwind CSS + Leaflet.js           │
└───────────────────────────┬─────────────────────────────────┘
                            │  HTTP / REST (JSON)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   FastAPI (Python 3.10+)                     │
│  /api/v1/health   /coverage   /population   /towers         │
└───────────────────────────┬─────────────────────────────────┘
                            │  SQLAlchemy (async)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│          PostgreSQL 15 + PostGIS 3                          │
│   districts · coverage_zones · coverage_gaps · towers       │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            ▼                               ▼
  GeoPandas / Shapely               Greedy Coverage
  (geospatial processing)           (algorithms/)
```

### Request Flow

```
User opens map
  → React fetches /api/v1/coverage/gaps?district=Tumkur
    → FastAPI queries PostGIS for gap polygons
      → Returns GeoJSON
        → Leaflet renders coverage-gap layer on map
```

---

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Frontend** | React | 18.x |
| | Vite | 5.x |
| | Tailwind CSS | 3.x |
| | Leaflet.js / react-leaflet | 1.9.x / 4.x |
| **Backend** | Python | 3.10+ |
| | FastAPI | 0.111 |
| | Uvicorn | 0.29 |
| | SQLAlchemy (async) | 2.x |
| **Database** | PostgreSQL | 15 |
| | PostGIS | 3.x |
| **Geospatial** | GeoPandas | 0.14 |
| | Shapely | 2.x |
| | PyProj | 3.6 |
| **Optimisation** | Greedy Max-Coverage | custom |

---

## Repository Structure

```
rural-coverage-gap-mapper/
│
├── frontend/                   # React + Vite single-page application
│   ├── src/
│   │   ├── pages/              # Route-level page components
│   │   │   └── MapView.jsx     # Primary map view
│   │   ├── components/         # Reusable UI components
│   │   ├── hooks/              # Custom React hooks
│   │   │   └── useHealthCheck.js
│   │   ├── utils/
│   │   │   └── api.js          # Fetch wrappers for all API calls
│   │   ├── assets/             # Static assets (SVG icons, images)
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── index.css           # Tailwind entry point
│   ├── public/                 # Served verbatim by Vite
│   ├── index.html
│   ├── vite.config.js
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   └── package.json
│
├── backend/                    # FastAPI application
│   ├── app/
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── endpoints/
│   │   │       │   └── health.py    # GET /api/v1/health
│   │   │       └── router.py        # v1 API router
│   │   ├── core/
│   │   │   └── config.py            # Pydantic settings
│   │   ├── db/
│   │   │   └── session.py           # Async SQLAlchemy engine + get_db
│   │   ├── models/                  # ORM models (future)
│   │   ├── schemas/                 # Pydantic request/response schemas (future)
│   │   ├── services/                # Business logic (future)
│   │   └── main.py                  # FastAPI app factory
│   ├── requirements.txt
│   ├── pytest.ini
│   └── .env.example
│
├── algorithms/                 # Standalone geospatial algorithms
│   └── coverage/
│       └── greedy.py           # Greedy Max-Coverage (placeholder)
│
├── data/                       # Datasets (not committed to git)
│   ├── raw/                    # Unmodified source files
│   ├── processed/              # Cleaned / transformed
│   └── simulated/              # Synthetic MVP data
│
├── database/
│   ├── migrations/
│   │   └── 001_initial_schema.sql   # PostGIS schema bootstrap
│   └── seeds/                       # Seed scripts (future)
│
├── docs/                       # Architecture diagrams, API specs, ADRs
│
├── tests/
│   ├── backend/
│   │   └── test_health.py      # Backend unit / integration tests
│   ├── frontend/               # Vitest / React Testing Library (future)
│   └── algorithms/             # Algorithm unit tests (future)
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## Getting Started

### Prerequisites

| Tool | Minimum Version | Install |
|------|----------------|---------|
| Python | 3.10 | [python.org](https://www.python.org/downloads/) |
| Node.js | 18 LTS | [nodejs.org](https://nodejs.org/) |
| pnpm | 8+ | `npm install -g pnpm` |
| PostgreSQL | 15 | [postgresql.org](https://www.postgresql.org/download/) |
| PostGIS | 3.x | Bundled with PostgreSQL installers or `apt install postgis` |

### Backend Setup

```bash
# 1. Enter the backend directory
cd backend

# 2. Create and activate a virtual environment
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS / Linux:
source .venv/bin/activate

# 3. Install Python dependencies
pip install -r requirements.txt

# 4. Configure environment variables
copy .env.example .env   # Windows
# cp .env.example .env   # macOS / Linux
# Then edit .env with your database credentials
```

### Frontend Setup

```bash
# 1. Enter the frontend directory
cd frontend

# 2. Install Node dependencies
pnpm install

# 3. (Optional) Copy environment overrides
# The Vite dev proxy is already configured in vite.config.js
```

### Database Setup

```bash
# 1. Create the PostgreSQL database
psql -U postgres -c "CREATE DATABASE coverage_mapper;"

# 2. Run the schema bootstrap migration
psql -U postgres -d coverage_mapper -f database/migrations/001_initial_schema.sql
```

---

## Running the Application

### Backend (FastAPI)

```bash
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API will be available at:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health check**: http://localhost:8000/api/v1/health

### Frontend (React + Vite)

```bash
cd frontend
pnpm dev
```

Application will be available at: **http://localhost:5173**

> The Vite dev server proxies all `/api/*` requests to `http://localhost:8000`,
> so there is no CORS configuration required during development.

### Running Tests

```bash
# Backend tests
cd backend
pytest tests/ -v

# Frontend tests (once Vitest is configured)
cd frontend
pnpm test
```

---

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/health` | API health check |
| `GET` | `/api/v1/coverage/gaps` | Coverage gap polygons *(future)* |
| `GET` | `/api/v1/population/stats` | Population impact stats *(future)* |
| `GET` | `/api/v1/towers/recommendations` | Optimal tower locations *(future)* |
| `GET` | `/api/v1/districts` | Available districts *(future)* |

Full interactive documentation is available at `/docs` when the backend is running.

---

## Roadmap

- [x] **Sprint 0** — Monorepo scaffold, FastAPI health check, React base map
- [ ] **Sprint 1** — Ingest Karnataka district boundaries + tower data
- [ ] **Sprint 2** — Coverage gap computation (PostGIS + GeoPandas)
- [ ] **Sprint 3** — Population impact analysis
- [ ] **Sprint 4** — Greedy Maximum Coverage Algorithm implementation
- [ ] **Sprint 5** — Tower recommendation API + map layer
- [ ] **Sprint 6** — Dashboard (gap stats, population affected, priority ranking)
- [ ] **Sprint 7** — Expand to all 31 Karnataka districts

---

## Contributing

1. Fork the repository and create a feature branch: `git checkout -b feature/my-feature`
2. Follow the existing code style (Black + Ruff for Python, ESLint for JS).
3. Write tests for any new functionality.
4. Open a pull request with a clear description of the change.

---

*Built for SW-27 · Karnataka Rural Connectivity Initiative*
