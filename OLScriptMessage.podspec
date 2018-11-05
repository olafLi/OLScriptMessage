

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

  s.source_files = 'OLScriptMessage/Classes/Core/*' , 'OLScriptMessage/Classes/Operations/*'
  
  s.resource_bundles = {
    'OLScriptMessage' => ['OLScriptMessage/Assets/*.*']
  }


end
