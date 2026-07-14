{
  "$schema" = "https://starship.rs/config-schema.json";

  format = "$username$directory\${custom.directory_connector_active}\${custom.directory_connector_inactive}\${custom.git_branch_clean}\${custom.git_branch_dirty}$git_status$docker_context$nix_shell$fill$nodejs$java$rust$cmd_duration$time\n[󱞪](fg:accent) ";

  right_format = "$status\n";

  palette = "theme";

  directory = {
    format = "[ $path ]($style)";
    style = "bg:blue fg:bg";
    truncation_length = 3;
    truncation_symbol = "…/";
  };

  custom = {
    directory_connector_active = {
      command = "true";
      shell = [ "sh" ];
      when = ''[ -n "$IN_NIX_SHELL" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1'';
      format = "[](fg:blue bg:cyan)";
    };
    directory_connector_inactive = {
      command = "true";
      shell = [ "sh" ];
      when = ''! ( [ -n "$IN_NIX_SHELL" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1 )'';
      format = "[](fg:blue bg:bg)";
    };
    git_branch_clean = {
      command = "git branch --show-current";
      require_repo = true;
      when = ''[ -z "$(git status --porcelain 2>/dev/null)" ]'';
      style = "bg:cyan fg:bg";
      format = "[  $output ]($style)[](bg:bg fg:cyan)";
    };
    git_branch_dirty = {
      command = "git branch --show-current";
      require_repo = true;
      when = ''[ -n "$(git status --porcelain 2>/dev/null)" ]'';
      style = "bg:cyan fg:bg";
      format = "[  $output ]($style)[](bg:bg_select fg:cyan)";
    };
  };

  fill = {
    style = "fg:bg_select";
    symbol = " ";
  };

  git_status = {
    disabled = false;
    style = "bg:bg_select fg:error";
    format = "([ $all_status$ahead_behind]($style))[](bg:bg fg:bg_select)";
    up_to_date = "[✓](bg:bg_select fg:accent)";
    stashed = "[\\$](bg:bg_select fg:accent)";
    deleted = "[✘\\($count\\)](bg:bg_select fg:error)";
    renamed = "[»\\($count\\)](bg:bg_select fg:accent)";
    modified = "[!\\($count\\)](bg:bg_select fg:warning)";
    staged = "[++\\($count\\)](bg:bg_select fg:warning)";
    untracked = "[?\\($count\\)](bg:bg_select fg:warning)";
    ahead = "[⇡\\(\${count}\\)](bg:bg_select fg:cyan)";
    behind = "[⇣\\(\${count}\\)](bg:bg_select fg:accent2)";
    diverged = "⇕[\\[](bg:bg_select fg:accent)[⇡\\(\${ahead_count}\\)](bg:bg_select fg:cyan)[⇣\\(\${behind_count}\\)](bg:bg_select fg:accent2)[\\]](bg:bg_select fg:accent)";
  };

  time = {
    disabled = false;
    format = "[](fg:accent2 bg:warning)[ $time ]($style)";
    style = "bg:accent2 fg:bg";
    use_12hr = false;
  };

  username = {
    disabled = false;
    format = "[ @THEME_ICON@ $user ]($style)[](fg:fg_faint bg:blue)";
    show_always = true;
    style_root = "bg:fg_faint fg:bg_alt";
    style_user = "bg:fg_faint fg:bg_alt";
  };

  java = {
    style = "bg:blue fg:bg";
    format = "[ $symbol$version ]($style)[](fg:blue bg:blue)";
    disabled = false;
    symbol = " ";
  };

  nodejs = {
    style = "bg:blue fg:bg";
    format = "[](fg:blue)[ $symbol$version ]($style)[](fg:blue bg:blue)";
    disabled = false;
    symbol = "󰎙 ";
  };

  rust = {
    style = "bg:blue fg:bg";
    format = "[ $symbol$version ]($style)[](fg:blue bg:warning)";
    disabled = false;
    symbol = " ";
  };

  nix_shell = {
    style = "bg:cyan fg:bg";
    format = "[ $symbol$state ]($style)[](fg:cyan)";
    disabled = false;
    symbol = "❄ ";
  };

  docker_context = {
    style = "bg:cyan fg:bg";
    format = "[ $symbol$context ]($style)[](fg:cyan bg:cyan)";
    disabled = false;
    symbol = "🐳 ";
    only_with_files = true;
  };

  cmd_duration = {
    style = "bg:warning fg:bg";
    format = "[](fg:warning bg:bg)[ ⏱ $duration ]($style)";
    disabled = false;
    min_time = 0;
  };

  status = {
    style = "bg:error fg:bg";
    format = "[](fg:error)[ ✘ $status ]($style)";
    disabled = false;
  };
}
