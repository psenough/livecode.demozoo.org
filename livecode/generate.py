from flask_frozen import Freezer
from website import app

app.config.update(
    FREEZER_DESTINATION="../public", FREEZER_REMOVE_EXTRA_FILES=False
)

freezer = Freezer(app)
