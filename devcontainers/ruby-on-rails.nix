{ dockerTools, ruby, bundix, mruby, rails-new, foodogsquaredLib }:

foodogsquaredLib.buildDockerImage {
  name = "ruby-on-rails-${ruby.version}";
  tag = "ror-${ruby.version}";
  contents = [ ruby bundix mruby rails-new ];
}
