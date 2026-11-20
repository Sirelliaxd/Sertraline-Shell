# Privileged actions without a password

Two rows in the network menu need root: `random mac` (`macchanger`) and `monitor mode` (`iw`).
Out of the box `pkexec` asks for a password every time. This is how that was turned off for those
two actions only, what it costs, and how to undo it.

The files live in `system/polkit/` and are installed into the system, so they are not part of the
shell's own config directory.

## How pkexec authorises a command

1. The shell runs `pkexec macchanger -r wlan0`.
2. `pkexec` asks polkitd "may this session run this program as root?".
3. polkitd picks a polkit ACTION for the request. By default that is the catch-all
   `org.freedesktop.policykit.exec`, which every pkexec invocation shares.
4. polkitd evaluates that action's DEFAULTS, then any JS RULES, and answers. `auth_admin` means
   "show the authentication dialog", `yes` means "run it".
5. If the answer was yes, `pkexec` execs the program as root.

Two files change that answer for two programs and nothing else:

- an ACTION file, which gives each program its own action id instead of the catch-all one, and
  leaves the defaults at `auth_admin_keep` (prompt),
- a RULE file, which returns `yes` for exactly those three action ids, for one user, in an active
  local session.

## The action file

`system/polkit/org.sertraline.network.policy`, installed to
`/usr/share/polkit-1/actions/org.sertraline.network.policy`. It declares three actions, each with
two annotations that tell `pkexec` when to use it instead of the catch-all action:

```xml
<action id="org.sertraline.network.macchanger.random">
  <defaults>
    <allow_any>auth_admin</allow_any>
    <allow_inactive>auth_admin</allow_inactive>
    <allow_active>auth_admin_keep</allow_active>
  </defaults>
  <annotate key="org.freedesktop.policykit.exec.path">/usr/bin/macchanger</annotate>
  <annotate key="org.freedesktop.policykit.exec.argv1">-r</annotate>
</action>
```

| Action id | Program | First argument | Covers |
| --- | --- | --- | --- |
| `org.sertraline.network.macchanger.random` | `/usr/bin/macchanger` | `-r` | randomising a MAC |
| `org.sertraline.network.macchanger.permanent` | `/usr/bin/macchanger` | `-p` | restoring the permanent MAC |
| `org.sertraline.network.iw.device` | `/usr/bin/iw` | `dev` | every `iw dev ...` command |

`exec.path` has to be the resolved absolute path, which is why the file names `/usr/bin/...` rather
than relying on `$PATH`. `argv1` is matched exactly against the first argument, so `macchanger -r`
and `macchanger -p` are two separate actions while `macchanger -s` (or any other flag) keeps the
catch-all action and still prompts.

The defaults are deliberately left at `auth_admin_keep`: this file on its own grants nothing, and
deleting the rule file is a complete revert.

## The rule file

`system/polkit/49-sertraline-network.rules`, installed to
`/etc/polkit-1/rules.d/49-sertraline-network.rules`:

```js
polkit.addRule(function(action, subject) {
    if ((action.id == "org.sertraline.network.macchanger.random" ||
         action.id == "org.sertraline.network.macchanger.permanent" ||
         action.id == "org.sertraline.network.iw.device") &&
        subject.user == "stella" &&
        subject.local &&
        subject.active) {
        return polkit.Result.YES;
    }
});
```

- The three ids are listed one by one rather than prefix-matched, so a future
  `org.sertraline.network.*` action does not inherit the grant by accident.
- `subject.user == "stella"` keeps other local accounts out. `subject.isInGroup("wheel")` is the
  variant to use if the machine has several administrators (stella is in `wheel` here).
- `subject.local && subject.active` keeps remote sessions out: over SSH there is no active local
  session, so the request falls back to the prompt (and with no agent there, it simply fails).
- Rules are re-read by polkitd when the rules directory changes, so this file takes effect
  immediately. Action files are read at startup, which is why the install below restarts polkitd.

## Install

Done on this machine; these are the steps, in case it is ever rebuilt:

```
cd ~/QuickShellConf/.config/quickshell
sudo install -m 644 system/polkit/org.sertraline.network.policy /usr/share/polkit-1/actions/
sudo install -m 644 system/polkit/49-sertraline-network.rules /etc/polkit-1/rules.d/
sudo pkill polkitd
```

`pkill polkitd` rather than `systemctl restart polkit` because this host has no systemd, and no
runit service for polkitd either: polkitd is D-Bus activated
(`/usr/share/dbus-1/system-services/org.freedesktop.PolicyKit1.service`), so killing it just makes
D-Bus start a fresh one on the next request, which re-reads the action files.

The install needs root, which is the one step the shell cannot do for itself.

## Verifying it

```
pkaction | grep sertraline                     # the three actions are known to polkit
time pkexec iw dev wlan0 info                  # root, no dialog, milliseconds
pkexec macchanger -r nonexistent0              # authorised, then macchanger's own "No such device"
timeout 3 pkexec macchanger -s nonexistent0    # NOT in the policy: waits for authentication
```

The first two are the positive cases. `iw dev wlan0 info` is a read-only command, so it proves the
whole chain (pkexec picks the annotated action, the rule answers yes, the program runs as root)
without changing anything. `macchanger -r nonexistent0` fails inside macchanger on an interface that
does not exist, which proves the authorisation and the `argv1` routing without touching a real
interface. The third command is the negative control: `-s` has no action of its own, so it falls
back to the catch-all action and waits for a password. If it returns instantly, the grant is wider
than intended.

Measured on this machine: `pkexec iw dev wlan0 info` returns in about 16 ms, and
`pkexec macchanger -r nonexistent0` in about 25 ms, both with no dialog. The real `-r` and `-p`
invocations on `wlan0` were NOT executed, because they take the interface down and drop the
connection.

`pkcheck --action-id org.sertraline.network.iw.device --process $$ -u stella` reports "needs
authentication" even when the rule works: the subject it builds from a bare uid is not an active
session subject, so `subject.active` is false and the rule does not match. Use the `pkexec` runs
above, not `pkcheck`, to test this.

## What it gives away

| | |
| --- | --- |
| Granted | `macchanger -r` and `macchanger -p` on any interface, and every `iw dev ...` command, run as root, no prompt, for user `stella` in an active local session |
| Not granted | a shell, arbitrary programs, file access, `iw phy ...` commands, any other `macchanger` flag |
| Who can use it | code running as stella. A malicious browser extension, a compromised package or a bad build script can now change the MAC and reconfigure the wireless interface silently, where before it would have had to make a password dialog appear. It cannot become root through these actions |
| Physical access | unchanged: whoever sits at an unlocked session could already click the rows in the menu |
| Remote | unchanged: SSH sessions are not covered by the rule and still get the prompt |

The `iw dev` grant is the broadest part of it: `iw dev <iface> set type monitor` is what the menu
needs, but the same action also covers `iw dev <iface> interface add`, `set mtu`, `set txpower`,
`connect` to an open network and the rest of the per-interface commands. Narrowing that to the one
verb needs a different mechanism, see below.

## Alternatives, and why they were not used

- **`allow_active=yes` in the action defaults, no rule file.** One file instead of two, and the
  same effect, but it grants every local active user rather than one account. Use it if the machine
  has a single account and a second file is unwanted; the rule file was kept because it names the
  user and can be deleted on its own.
- **`setcap cap_net_admin+ep /usr/bin/{macchanger,iw}`.** No polkit, no agent, no rule, works from
  any context. Two problems: the capability applies to anyone who can execute the binary, which is
  broader than one user, and pacman replaces those files on every upgrade, so the capability
  disappears and the toggles start failing with no prompt and no explanation. The polkit route
  degrades to a password dialog instead of failing silently.
- **A root-owned helper script with fixed verbs** (`mac-random`, `mac-restore`, `monitor-on`,
  `monitor-off`, interface validated against a whitelist) plus an action for it keyed on `argv1`.
  This is the narrowest option: the grant becomes four exact operations instead of "all of
  macchanger and all of `iw dev`". It costs a new root-owned program on the system that must never
  be writable by the user (a writable helper plus a passwordless rule is a root shell), and any bug
  in its argument handling is a privilege escalation. Worth doing on a shared machine; overkill for
  a single-user laptop.
- **`sudoers` with `NOPASSWD`.** The same power, but through a setuid root binary and a `visudo`
  edit, and the grant is invisible to `pkaction`. The polkit files keep the policy in one place and
  in polkit's own language.

## Undo

```
sudo rm /etc/polkit-1/rules.d/49-sertraline-network.rules      # prompt comes back
sudo rm /usr/share/polkit-1/actions/org.sertraline.network.policy
sudo pkill polkitd                                             # only needed for the second one
```

Removing the rule file is enough on its own: the action defaults are `auth_admin_keep`, so the rows
in the menu go back to asking for a password.

## What the shell side needed

Nothing. `modules/NetInfo.qml` still runs `pkexec macchanger -r|-p <interface>` and
`pkexec iw dev <interface> set type monitor|managed`; the annotations in the action file are what
make polkit route those to the new actions, and the rule is what makes them passwordless. There is
no second code path to keep in sync, and a machine without these files installed behaves exactly as
it did before: a password dialog.
