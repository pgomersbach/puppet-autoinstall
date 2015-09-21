Facter.add(:bashshellshock) do
  confine :kernel => 'Linux'
  setcode "env x='() { :;}; :; echo vulnerable' bash -c : 2>&1 | grep 'vulnerable' || echo 'not_vulnerable'"
end
