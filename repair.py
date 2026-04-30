import sys

with open("lib/screens/farmers/sell/views/sell_chicken_view.dart", "r") as f:
    text = f.read()

# Revert IntrinsicHeight additions
text = text.replace("child: IntrinsicHeight(\n              child: Row(\n                crossAxisAlignment: CrossAxisAlignment.stretch,", "child: Row(\n              crossAxisAlignment: CrossAxisAlignment.start,")
text = text.replace("            },\n            ),\n          ),\n        );\n      },\n    );\n  }", "            },\n          ),\n        );\n      },\n    );\n  }")

# brute force repair to get it back to compiling state:
