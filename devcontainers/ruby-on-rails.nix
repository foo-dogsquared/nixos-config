{ dockerTools, ruby, bundix, mruby, rails-new, foodogsquaredLib }:

foodogsquaredLib.buildDockerImage {
  name = "ruby-on-rails";
  tag = "ror-${ruby.version}";
  contents = [ ruby bundix mruby rails-new ];
}
