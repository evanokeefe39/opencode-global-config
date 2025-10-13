import logging
import os

LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()

handler = logging.StreamHandler()
fmt = "%(asctime)s %(levelname)s %(name)s %(message)s"
handler.setFormatter(logging.Formatter(fmt))

logger = logging.getLogger("app")
logger.setLevel(LEVEL)
logger.addHandler(handler)

def get_logger(name: str = "app"):
    return logging.getLogger(name)
