# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'

#pod 'MagicalRecord'
pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord.git', :branch => 'develop'

target 'CoreDataTest' do

end

target 'CoreDataTestTests' do

end

post_install do |installer|
    installer.project.targets.each do |target|
        #print out the target names
        #        puts "#{target.name}"#
        
        target.build_configurations.each do |config|
            s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
            #            puts "-->"+config.name
            if s != nil then
                
                # remove logging for MagicalRecord
                if target.name == "Pods-MagicalRecord"
                    unless s.include? "MR_LOGGING_ENABLED=1"
                        s.push('MR_LOGGING_ENABLED=1');
                        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
                    end
                end
                
                #print out the pre-processor definitions
                #                s.each do |element|
                #    t = element
                #    if t==nil then t=" " end
                #    puts "   -->"+t
                #end
            end
        end
    end
end
