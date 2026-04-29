import sqlite3
import tempfile
import unittest
from importlib.machinery import SourceFileLoader
from pathlib import Path
from types import SimpleNamespace


ARGUS_PATH = Path(__file__).resolve().parents[1] / "bin" / "argus"
argus = SourceFileLoader("argus_cli", str(ARGUS_PATH)).load_module()


def init_db(db_path: str):
    conn = sqlite3.connect(db_path)
    conn.execute(
        """
        CREATE TABLE notifications (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            url TEXT,
            dismissed INTEGER DEFAULT 0,
            acted_at TEXT,
            seen_at TEXT
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE escalations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            title TEXT,
            detail TEXT
        )
        """
    )
    conn.commit()
    conn.close()


class TestNotifAudit(unittest.TestCase):
    def test_audit_handles_sqlite_row_without_get(self):
        with tempfile.TemporaryDirectory() as td:
            db_path = str(Path(td) / "argus.db")
            init_db(db_path)

            conn = sqlite3.connect(db_path)
            conn.execute(
                """
                INSERT INTO notifications (id, title, url, dismissed, acted_at, seen_at)
                VALUES (?, ?, ?, 0, NULL, '2000-01-01T00:00:00')
                """,
                ("n1", "old stale notification", None),
            )
            conn.commit()
            conn.close()

            def fake_get_db():
                c = sqlite3.connect(db_path)
                c.row_factory = sqlite3.Row
                return c

            argus.get_db = fake_get_db
            argus.cmd_notif_audit(SimpleNamespace(stale_hours=4))

            conn = sqlite3.connect(db_path)
            row = conn.execute("SELECT category, detail FROM escalations").fetchone()
            conn.close()

            self.assertIsNotNone(row)
            self.assertEqual(row[0], "stale-notification")
            self.assertIn("Notification n1 has been pending", row[1])

    def test_audit_no_stale_notifications_creates_no_escalation(self):
        with tempfile.TemporaryDirectory() as td:
            db_path = str(Path(td) / "argus.db")
            init_db(db_path)

            conn = sqlite3.connect(db_path)
            conn.execute(
                """
                INSERT INTO notifications (id, title, url, dismissed, acted_at, seen_at)
                VALUES (?, ?, ?, 0, NULL, '2999-01-01T00:00:00')
                """,
                ("n2", "fresh notification", "https://example.com"),
            )
            conn.commit()
            conn.close()

            def fake_get_db():
                c = sqlite3.connect(db_path)
                c.row_factory = sqlite3.Row
                return c

            argus.get_db = fake_get_db
            argus.cmd_notif_audit(SimpleNamespace(stale_hours=4))

            conn = sqlite3.connect(db_path)
            count = conn.execute("SELECT COUNT(*) FROM escalations").fetchone()[0]
            conn.close()

            self.assertEqual(count, 0)


if __name__ == "__main__":
    unittest.main()
