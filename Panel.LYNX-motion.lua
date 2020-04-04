-- Panel.LYNX-motion.lua
-- v1.0
-- Extended lynx-motion style
-- Very convenient navigation in panels with elevators through empty subfolders and etc.
-- Keys: <kbd>Left</kbd> <kbd>Right</kbd> <kbd>Enter</kbd>

Macro {
area="Shell"; key="Left"; flags="EmptyCommandLine EnableOutput "; description="LYNX-style motion";
condition = function() return APanel.Visible and APanel.ColumnCount==1 end;
action = function()
  Keys('CtrlPgUp')
end;
}

Macro {
area="Shell"; key="Right"; flags="EmptyCommandLine EnableOutput"; description="LYNX-style motion";
condition = function() return APanel.Visible and APanel.ColumnCount==1 end;
action = function()
  Keys('CtrlPgDn')
  if Area.Current=="Shell" and APanel.Current==".." and panel.GetPanelInfo(nil,1).ItemsNumber>1 then Panel.SetPosIdx(0,2) end
end;
}

Macro {
area="Shell"; key="Enter"; flags="EmptyCommandLine EnableOutput"; description="LYNX-style motion";
condition = function() return APanel.Visible end;
action = function()
  if APanel.Current==".." then
    Keys('CtrlPgUp')
    while Area.Current=="Shell" and panel.GetPanelItem(nil,1,1).FileName==".." do
      if panel.GetPanelInfo(nil,1).ItemsNumber<=2 and not APanel.Path:match("^[\\/]?$") then Keys('CtrlPgUp') else break end
    end
    if APanel.Current==".." and panel.GetPanelInfo(nil,1).ItemsNumber>1 then Panel.SetPosIdx(0,2) end
  elseif panel.GetCurrentPanelItem(nil,1).FileAttributes:find("d") then
    Keys('CtrlPgDn')
    while Area.Current=="Shell" do
      if APanel.Current==".." and panel.GetPanelInfo(nil,1).ItemsNumber>1 then Panel.SetPosIdx(0,2) end
      if panel.GetPanelInfo(nil,1).ItemsNumber<=2 and APanel.Current~=".." and panel.GetCurrentPanelItem(nil,1).FileAttributes:find("d") then Keys('CtrlPgDn') else break end
    end
  else
    Keys('Enter')
  end
end;
}

Macro {
area="Disks"; key="Right"; flags="EmptyCommandLine EnableOutput"; description="LYNX-style motion";
condition = function() return APanel.Visible end;
action = function() Keys('Enter') end;
}

Macro {
area="Disks"; key="Left"; flags="EmptyCommandLine EnableOutput"; description="LYNX-style motion";
condition = function() return APanel.Visible end;
action = function() end;
}

Macro {
area="Dialog"; key="Right"; flags="EmptyCommandLine EnableOutput"; description="LYNX-style motion";
condition = function() return APanel.Visible and Dlg.Owner=="3106D308-A685-415C-96E6-84C8EBB361FE" and Dlg.Id=="3731617B-3037-6363-632D-353933332D34" end;
action = function()
  Keys('Esc CtrlPgDn')
  if Area.Current=="Shell" and APanel.Current==".." and panel.GetPanelInfo(nil,1).ItemsNumber>1 then Panel.SetPosIdx(0,2) end
end;
}
