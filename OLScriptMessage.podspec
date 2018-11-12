

Pod::Spec.new do |s|
  s.name             = 'OLScriptMessage'
  s.version          = '0.1.0'
  s.summary          = 'A short description of OLScriptMessage.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/olafLi/OLScriptMessage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'olafLi' => 'litengfei@winkind-tech.com' }
  s.source           = { :git => 'https://github.com/olafLi/OLScriptMessage.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'OLScriptMessage/Classes/Core/*'
  
  s.resource_bundles = {
    'OLScriptMessage' => ['OLScriptMessage/Assets/*.*']
  }

  s.subspec 'Navigation' do |spec|
      spec.source_files = 'OLScriptMessage/Classes/FuncModule/Navigation/**/*'
  end
  s.subspec 'Media' do |spec|
      spec.source_files = 'OLScriptMessage/Classes/FuncModule/Media/**/*'
  end
  s.subspec 'Authorization' do |spec|
      spec.source_files = 'OLScriptMessage/Classes/FuncModule/Authorization/**/*'
  end
  s.subspec 'Location' do |spec|
      spec.source_files = 'OLScriptMessage/Classes/FuncModule/Location/**/*'
  end

  s.subspec 'Phone' do |spec|
      spec.source_files = 'OLScriptMessage/Classes/FuncModule/Phone/**/*'
  end

  s.subspec 'Speech' do |spec|
      spec.source_files = 'OLScriptMessage/Classes/FuncModule/Speech/**/*'
  end

  s.default_subspecs = 'Navigation', 'Media','Authorization'

end
