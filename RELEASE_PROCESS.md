## Publishing a new version

To publish a new version:

* Ensure you have access to publish the package (see docs [here](https://hexdocs.pm/hex/Mix.Tasks.Hex.Owner.html))
* Update the `version` string in `mix.exs` according to [SemVer](https://semver.org/spec/v2.0.0.html)
* Run `mix hex.publish`
