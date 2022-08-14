# Publishing Jsonrs

From: https://hexdocs.pm/rustler_precompiled/precompilation_guide.html#recommended-flow

- Bump dep version in `mix.exs`
- `git tag v${mix_version}` the git tag must be `v` prepended to the Mix project version
- `git push --tags`
- Wait for the associated GitHub actions to finish
- Run `mix rustler_precompiled.download Jsonrs --all`
- Release the packge to hex.pm `mix hex.publish` (making sure to include the correct files (**untested!**)
