# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2020 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/spring_boot_utils'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for contributing an mTLS client certificate mapper to the application.
    class ClientCertificateMapper < JavaBuildpack::Component::VersionedDependencyComponent
      include JavaBuildpack::Util

      def initialize(context)
        @spring_boot_utils = JavaBuildpack::Util::SpringBootUtils.new
        @configuration = context[:configuration]
        print '@configuration: ' + @configuration.to_s

        super(context)
      end

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        if spring_boot_3?
          my_configuration = @configuration
          my_configuration['version'] = 2
          print 'my_configuration: ' + my_configuration.to_s

          @version, @uri = JavaBuildpack::Repository::ConfiguredItem.find_item(@component_name, my_configuration)
          print '@version: ' + @version.to_s + ' and @uri:' + @uri.to_s
          # JavaBuildpack::Component::BaseComponent.download_jar(version_2, uri_for_version_2, "#{@droplet.component_id}-#{version_2}.jar")
        end
        download_jar
        @droplet.additional_libraries << (@droplet.sandbox + jar_name)
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        @droplet.additional_libraries << (@droplet.sandbox + jar_name)
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        true
      end

      private

      def spring_boot_3?
        print '@application.details: ' + @application.details.to_s
        @spring_boot_utils.is?(@application) && Gem::Version.new((@spring_boot_utils.version @application)).release >=
          Gem::Version.new('3.0.0')
      end

    end

  end
end
