from __future__ import annotations

import os
import shutil
import sys

from winter_cli.plugins.types import (
    ActionScope,
    FeatureEnvironmentContext,
    PluginRegistration,
    TuiAction,
)


class DeltaDiffPlugin:
    name = "delta-diff"

    def register(self, config: object) -> PluginRegistration:
        return PluginRegistration(
            tui_actions=[
                TuiAction(
                    name="deltadiff",
                    scope=ActionScope.feature_environment,
                    key="D",
                    description="Delta Diff",
                    handler=self._handle_diff,
                ),
            ],
        )

    def _handle_diff(self, ctx: FeatureEnvironmentContext) -> None:
        delta = shutil.which("delta")
        pager = f"| {delta} --side-by-side --navigate" if delta else ""
        cmd = f"{sys.executable} -m winter_cli.cli ws diff {ctx.environment.name} --branch {pager}"
        if ctx.suspend is not None:
            with ctx.suspend():
                os.system(cmd)


def create_plugin() -> DeltaDiffPlugin:
    return DeltaDiffPlugin()
