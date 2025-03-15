{ dockerTools, ruby, bundix, mruby, rails-new, foodogsquaredLib }:

foodogsquaredLib.buildDockerImage {
  name = "ruby-on-rails";
  contents = [ ruby bundix mruby rails-new ];
}
