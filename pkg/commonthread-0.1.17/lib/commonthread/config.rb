#!/usr/bin/env ruby

# Sitewide default config, this will be overridden by user config generally
$default_config = {
      :adapter    => "postgresql",
      :database   => "commonthread",
      :username   => "commonthread",
      :password   => "",
      :host       => "localhost"
   }