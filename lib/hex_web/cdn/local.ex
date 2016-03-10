defmodule HexWeb.CDN.Local do
  @behaviour HexWeb.CDN

  def purge_key(_service, _key), do: :ok
  def public_ips, do: [{<<127, 0, 0, 0>>, 24}]
end
