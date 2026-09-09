import os
import json
import sqlite3
import datetime
from typing import Dict, List, Optional, Any
from .config import settings

DB_FILE = os.path.join(settings.DATA_DIR, "agriintel.db")
LEGACY_USERS_JSON = os.path.join(settings.DATA_DIR, "users_db.json")
LEGACY_SESSIONS_JSON = os.path.join(settings.DATA_DIR, "active_sessions.json")

def get_db_connection() -> sqlite3.Connection:
    os.makedirs(os.path.dirname(DB_FILE), exist_ok=True)
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # 1. Users Table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT,
            mobile TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            village TEXT NOT NULL,
            district TEXT NOT NULL,
            state TEXT NOT NULL DEFAULT 'Maharashtra',
            farm_size_acres REAL NOT NULL DEFAULT 2.5,
            selected_crops TEXT NOT NULL DEFAULT '["Grapes", "Onion"]',
            language TEXT NOT NULL DEFAULT 'mr',
            farming_experience_years INTEGER NOT NULL DEFAULT 5,
            farms TEXT NOT NULL DEFAULT '[]',
            is_demo INTEGER NOT NULL DEFAULT 1,
            verification_status TEXT NOT NULL DEFAULT 'DEMO',
            created_at TEXT,
            updated_at TEXT
        )
    """)

    # 2. Sessions Table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS sessions (
            token TEXT PRIMARY KEY,
            mobile TEXT NOT NULL,
            user_id TEXT NOT NULL,
            created_at TEXT,
            is_active INTEGER DEFAULT 1
        )
    """)

    # 3. App Meta Table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS app_meta (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    """)

    # 4. User Diagnostic & Advisory History Table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_history (
            record_id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            crop TEXT NOT NULL,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            details TEXT NOT NULL,
            blockchain_hash TEXT,
            timestamp TEXT,
            verification_status TEXT DEFAULT 'DEMO'
        )
    """)

    conn.commit()

    # Seed or migrate legacy JSON data if table is empty
    cursor.execute("SELECT COUNT(*) as count FROM users")
    count = cursor.fetchone()["count"]
    if count == 0:
        _seed_or_migrate_users(cursor)
        conn.commit()

    conn.close()

def _seed_or_migrate_users(cursor: sqlite3.Cursor):
    migrated = False
    if os.path.exists(LEGACY_USERS_JSON):
        try:
            with open(LEGACY_USERS_JSON, "r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, dict):
                    now_str = datetime.datetime.now(datetime.timezone.utc).isoformat()
                    for mob, u in data.items():
                        cursor.execute("""
                            INSERT OR REPLACE INTO users (
                                id, name, email, mobile, password, village, district, state,
                                farm_size_acres, selected_crops, language, farming_experience_years,
                                farms, is_demo, verification_status, created_at, updated_at
                            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """, (
                            u.get("id", f"usr_{mob}"),
                            u.get("name", "Farmer"),
                            u.get("email"),
                            u.get("mobile", mob),
                            u.get("password", "demo_password"),
                            u.get("village", "Pune"),
                            u.get("district", "Pune"),
                            u.get("state", "Maharashtra"),
                            float(u.get("farm_size_acres", 3.0)),
                            json.dumps(u.get("selected_crops", ["Grapes", "Onion"])),
                            u.get("language", "mr"),
                            int(u.get("farming_experience_years", 5)),
                            json.dumps(u.get("farms", [])),
                            1 if u.get("is_demo", True) else 0,
                            u.get("verification_status", "DEMO"),
                            now_str,
                            now_str
                        ))
                    migrated = True
        except Exception as e:
            print(f"Error migrating legacy users: {e}")

    if not migrated:
        now_str = datetime.datetime.now(datetime.timezone.utc).isoformat()
        cursor.execute("""
            INSERT OR REPLACE INTO users (
                id, name, email, mobile, password, village, district, state,
                farm_size_acres, selected_crops, language, farming_experience_years,
                farms, is_demo, verification_status, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            "usr_demo_001",
            "Pranali Patil",
            "pranali.farmer@agriintel.in",
            "9876543210",
            "demo_password",
            "Junnar",
            "Pune",
            "Maharashtra",
            4.5,
            json.dumps(["Grapes", "Onion"]),
            "en",
            8,
            json.dumps([{
                "farm_id": "farm_001",
                "user_id": "usr_demo_001",
                "farm_name": "Shivneri Vineyards & Onion Plot",
                "village": "Junnar",
                "district": "Pune",
                "state": "Maharashtra",
                "latitude": 19.2087,
                "longitude": 73.8789,
                "area": 4.5,
                "area_unit": "Acres",
                "soil_type": "Medium Black Clay Loam",
                "irrigation_type": "Drip Irrigation",
                "created_at": now_str,
                "updated_at": now_str
            }]),
            1,
            "DEMO",
            now_str,
            now_str
        ))
        cursor.execute("""
            INSERT OR REPLACE INTO sessions (token, mobile, user_id, created_at, is_active)
            VALUES (?, ?, ?, ?, 1)
        """, ("demo_token_secret_123", "9876543210", "usr_demo_001", now_str))
        cursor.execute("""
            INSERT OR REPLACE INTO app_meta (key, value) VALUES ('latest_active_user', '9876543210')
        """)

def _row_to_user_dict(row: sqlite3.Row) -> dict:
    if not row:
        return {}
    d = dict(row)
    if isinstance(d.get("selected_crops"), str):
        try:
            d["selected_crops"] = json.loads(d["selected_crops"])
        except Exception:
            d["selected_crops"] = ["Grapes", "Onion"]
    if isinstance(d.get("farms"), str):
        try:
            d["farms"] = json.loads(d["farms"])
        except Exception:
            d["farms"] = []
    d["is_demo"] = bool(d.get("is_demo", 1))
    return d

def get_user_by_mobile(mobile: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE mobile = ?", (mobile,))
    row = cursor.fetchone()
    conn.close()
    return _row_to_user_dict(row) if row else None

def get_user_by_email(email: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
    row = cursor.fetchone()
    conn.close()
    return _row_to_user_dict(row) if row else None

def get_user_by_id(user_id: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    row = cursor.fetchone()
    conn.close()
    return _row_to_user_dict(row) if row else None

def get_user_by_token(token: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT u.* FROM users u
        JOIN sessions s ON u.mobile = s.mobile
        WHERE s.token = ? AND s.is_active = 1
    """, (token,))
    row = cursor.fetchone()
    conn.close()
    return _row_to_user_dict(row) if row else None

def get_latest_active_user() -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT value FROM app_meta WHERE key = 'latest_active_user'")
    meta_row = cursor.fetchone()
    if meta_row and meta_row["value"]:
        cursor.execute("SELECT * FROM users WHERE mobile = ?", (meta_row["value"],))
        user_row = cursor.fetchone()
        if user_row:
            conn.close()
            return _row_to_user_dict(user_row)
    
    # Fallback to the latest updated user
    cursor.execute("SELECT * FROM users ORDER BY updated_at DESC LIMIT 1")
    row = cursor.fetchone()
    conn.close()
    return _row_to_user_dict(row) if row else None

def save_user(user: dict) -> dict:
    now_str = datetime.datetime.now(datetime.timezone.utc).isoformat()
    conn = get_db_connection()
    cursor = conn.cursor()

    selected_crops_json = json.dumps(user.get("selected_crops", ["Grapes", "Onion"]))
    farms_json = json.dumps(user.get("farms", []))

    cursor.execute("""
        INSERT OR REPLACE INTO users (
            id, name, email, mobile, password, village, district, state,
            farm_size_acres, selected_crops, language, farming_experience_years,
            farms, is_demo, verification_status, created_at, updated_at
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?,
            COALESCE((SELECT created_at FROM users WHERE mobile = ?), ?),
            ?
        )
    """, (
        user.get("id"),
        user.get("name"),
        user.get("email"),
        user.get("mobile"),
        user.get("password", "demo_password"),
        user.get("village", "Pune"),
        user.get("district", "Pune"),
        user.get("state", "Maharashtra"),
        float(user.get("farm_size_acres", 2.5)),
        selected_crops_json,
        user.get("language", "mr"),
        int(user.get("farming_experience_years", 5)),
        farms_json,
        1 if user.get("is_demo", True) else 0,
        user.get("verification_status", "DEMO"),
        user.get("mobile"),
        now_str,
        now_str
    ))
    conn.commit()
    conn.close()

    # Sync back to JSON backup for cross-compatibility
    _sync_users_json_backup()
    return get_user_by_mobile(user["mobile"]) or user

def create_session(token: str, mobile: str, user_id: str):
    now_str = datetime.datetime.now(datetime.timezone.utc).isoformat()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT OR REPLACE INTO sessions (token, mobile, user_id, created_at, is_active)
        VALUES (?, ?, ?, ?, 1)
    """, (token, mobile, user_id, now_str))
    cursor.execute("""
        INSERT OR REPLACE INTO app_meta (key, value) VALUES ('latest_active_user', ?)
    """, (mobile,))
    conn.commit()
    conn.close()

def update_user_crops(mobile: str, crops: List[str]) -> Optional[dict]:
    now_str = datetime.datetime.now(datetime.timezone.utc).isoformat()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE users 
        SET selected_crops = ?, updated_at = ?
        WHERE mobile = ?
    """, (json.dumps(crops), now_str, mobile))
    cursor.execute("""
        INSERT OR REPLACE INTO app_meta (key, value) VALUES ('latest_active_user', ?)
    """, (mobile,))
    conn.commit()
    conn.close()

    _sync_users_json_backup()
    return get_user_by_mobile(mobile)

def _sync_users_json_backup():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users")
        rows = cursor.fetchall()
        conn.close()

        all_users = {}
        for r in rows:
            u = _row_to_user_dict(r)
            all_users[u["mobile"]] = u

        with open(LEGACY_USERS_JSON, "w", encoding="utf-8") as f:
            json.dump(all_users, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Error syncing JSON backup: {e}")

# Initialize DB on module import
init_db()
