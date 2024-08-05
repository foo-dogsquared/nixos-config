#!/usr/bin/env bash

# A specialized launcher intended to handle a bunch of things in runtime such
# as adding flags when in certain systems and running xdg-dbus-proxy if
# required. Take note, we don't enforce any security model whatsoever, it's
# just a launcher that adds `bwrap` arguments in runtime for certain
# situations.
#
# Take note, we have the following design constraints for this launcher:
#
# * Using only the nixpkgs runtime shell and a few common dependencies found on
# Unix-adjacent systems.
# * No additional command-line options which means no flags and command-line
# parsing. This is essentially just a Bubblewrap wrapper.
# * If we ever let the user configure things, it should be done with
# environment variables with `WRAPPER_MANAGER_BWRAP_LAUNCHER` prefix. It's very
# long but who cares.
# * Ideally, there should be no options to clear the environment in this
# launcher. Let the user do it themselves if they want.

declare -a additional_flags
: "${XDG_RUNTIME_DIR:="/run/user/$(id -u)"}"
: "${WRAPPER_MANAGER_BWRAP_LAUNCHER_BWRAP:="bwrap"}"
: "${WRAPPER_MANAGER_BWRAP_LAUNCHER_DBUS_PROXY:="xdg-dbus-proxy"}"
: "${WRAPPER_MANAGER_BWRAP_LAUNCHER_AUTOCONFIGURE:="1"}"

is_autoconfigured_or() {
    local service="$1"
    [ "${WRAPPER_MANAGER_BWRAP_LAUNCHER_AUTOCONFIGURE}" = "1" ] || [ "${service}" = "1" ]
}

# Bubblewrap is aggressively Linux-exclusive so we can add some things in here
# that are surely common within most Linux distros but just in case...
case "$(uname)" in
    Linux*)
        additional_flags+=(--proc /proc)
        additional_flags+=(--dev /dev)
        additional_flags+=(--dev-bind /dev/dri /dev/dri)
        additional_flags+=(--tmpfs /tmp)
        additional_flags+=(--ro-bind /sys/dev/char)
        additional_flags+=(--ro-bind /sys/devices/pci0000:00)

        # Check if we're in a NixOS system.
        if [[ -f /etc/NIXOS ]]; then
            additional_flags+=(--ro-bind /run/opengl-driver/ /run/opengl-driver/)

            if [[ -d /run/opengl-driver-32 ]]; then
                additional_flags+=(--ro-bind /run/opengl-driver-32 /run/opengl-driver-32/)
            fi
        fi
        ;;
esac

# TODO: Much of the flags added here are so far just cargo-culted lmao.
# Investigate it pls for the love of God.

# Bind Wayland if it's detected to be running on one.
if is_autoconfigured_or "${WRAPPER_MANAGER_BWRAP_LAUNCHER_WAYLAND}" && [ -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]; then
    additional_flags+=(--ro-bind "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}")
fi

# Bind Pipewire if it's detected.
if is_autoconfigured_or "${WRAPPER_MANAGER_BWRAP_LAUNCHER_PIPEWIRE}" && [ -S "${XDG_RUNTIME_DIR}/pipewire-0" ]; then
    additional_flags+=(--ro-bind "${XDG_RUNTIME_DIR}/pipewire-0")
fi

# Bind PulseAudio if it's detected and configured.
if is_autoconfigured_or "${WRAPPER_MANAGER_BWRAP_LAUNCHER_PULSEAUDIO}" && [ -e "${XDG_RUNTIME_DIR}/pulse/pid" ]; then
    additional_flags+=(--ro-bind "${XDG_RUNTIME_DIR}/pulse")
fi

# Bind X11 thingies if it's configured and detected.
if is_autoconfigured_or "${WRAPPER_MANAGER_BWRAP_LAUNCHER_X11}" && [ "${XAUTHORITY}" ]; then
    additional_flags+=(--ro-bind "${XAUTHORITY}")
    additional_flags+=(--ro-bind "/tmp/.X11-unix")
fi

# Fork the D-Bus proxy in case it is needed. We only need to know if its needed
# if the *DBUS_PROXY_ARGS envvar is set.
if [ -n "${WRAPPER_MANAGER_BWRAP_LAUNCHER_DBUS_PROXY_ARGS}" ]; then
    (
        ${WRAPPER_MANAGER_BWRAP_LAUNCHER_BWRAP} "${additional_flags[@]}" \
            -- "${WRAPPER_MANAGER_BWRAP_LAUNCHER_DBUS_PROXY}" "${WRAPPER_MANAGER_BWRAP_LAUNCHER_DBUS_PROXY_ARGS[@]}"
    ) &
fi

exec ${WRAPPER_MANAGER_BWRAP_LAUNCHER_BWRAP} "${additional_flags[@]}" "$@"
