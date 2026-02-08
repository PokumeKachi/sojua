_default:
    @just --choose

ARGS := "--features bevy/dynamic_linking"

build-release:
    cargo build --release --no-default-features

build: develop
    cargo build {{ARGS}}

run: develop
    cargo run {{ARGS}}

watch: develop
    cargo watch -x run {{ARGS}}

todo:
    taskwarrior-tui --taskdata .task

git:
    gitui

develop:
    @sh -c ' \
        h=$(nix hash path ./flake.nix); \
        old="$FLAKE_HASH"; \
        if [ "$old" != "$h" ]; then \
            echo "Entering flake shell..."; \
            FLAKE_HASH="$h" exec nix develop; \
        else \
            echo "Inside flake shell, skipping nix develop..."; \
        fi \
    '
