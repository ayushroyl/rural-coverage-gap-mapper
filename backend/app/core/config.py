from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    PROJECT_NAME: str = "Rural Coverage Gap Mapper"
    VERSION: str = "0.1.0"
    API_V1_PREFIX: str = "/api/v1"

    CORS_ORIGINS: List[str] = ["http://localhost:5173", "http://127.0.0.1:5173"]

    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/coverage_mapper"

    DEFAULT_CRS: str = "EPSG:32643"


settings = Settings()

