defmodule HexWeb.API.PackageView do
  use HexWeb.Web, :view
  import Ecto

  def render("index." <> _, %{packages: packages}),
    do: render_many(packages, __MODULE__, "package/index")
  def render("show." <> _, %{package: package}),
    do: render_one(package, __MODULE__, "package/show")

  def render("package/" <> view, %{package: package}) do
    package
    |> Map.take([:name, :inserted_at, :updated_at])
    |> Map.put(:meta, Map.take(package.meta, [:description, :licenses, :links, :maintainers]))
    |> Map.put(:url, package_url(HexWeb.Endpoint, :show, package))
    |> if_value(assoc_loaded?(package.releases), &load_releases(&1, get_params(view), package, package.releases))
    |> if_value(assoc_loaded?(package.downloads), &load_downloads(&1, package.downloads))
  end

  defp load_releases(entity, params, package, releases) do
    releases =
      Enum.map(releases, fn release ->
        version = to_string(release.version)
        release
        |> Map.take(params)
        |> Map.put(:url, release_url(HexWeb.Endpoint, :show, package, version))
      end)

    Map.put(entity, :releases, releases)
  end

  defp load_downloads(entity, downloads) do
    downloads =
      Enum.into(downloads, %{}, fn download ->
        {download.view, download.downloads}
      end)

    Map.put(entity, :downloads, downloads)
  end

  defp get_params("index"), do: [:version]
  defp get_params("show"), do: [:version, :inserted_at, :updated_at]
end
