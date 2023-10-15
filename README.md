# leti-scripts
Various scripts that I like to have available in different machines

Scripts:

* **recompress_to_xz.sh**: recompresses a compressed .gz, .bz2 or .lzop file to the .xz format.

  Requires installed packages: `gzip` `bzip2` `lzop` `xz` `pv`

* **git_backup_working_dir.sh**: saves current Git working copy (including the local repo) to a 
  backup file in the user's home directory in the format: `<repo-name>_<date>-<branch_name>.tar.xz`.
  Usable for https://xkcd.com/1597/.

  Requires installed packages: `git` `xz`

* **raid_audbile_check.sh**: audible check if Linux Software RAID is not degraded. If any of the
  MD RAID arrays are degraded, it will play a warning tone sequence trough the PC speaker that is
  built in the PC case (does not require extenal speakers).

  I use this as the simplest form of monitoring for RAID failure on a single
  home server that is not integrated into a more sophisticated monitoring software (for
  workstations, check out https://github.com/xtaran/systray-mdstat, if you have multiple servers
  or in a professional setting check out professional grade software, such as Nagios, Icinga,
  CheckMK, Zabbix, ...).

  Use **raid_beep_check.sh** to check that the machine's internal speaker works, that you can hear 
  it. and that the `beep` utility is correctly installed.

  Install the **raid-audible-check.crontab** `crontab -i raid-audible-check.crontab` to run
  the check automatically every 5 minutes. Scripts must be installed as root, since `mdadm`
  utility requires root privileges.

  Requires installed packages: `mdadm` `beep`
