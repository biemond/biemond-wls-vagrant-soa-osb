# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:opatch_exists, :type => :rvalue) do |args|
    
    patch_exists  = false
    oracleHomeArg = args[0].strip.downcase
    oracleHome    = oracleHomeArg.gsub("/","_").gsub("\\","_").gsub("c:","_c").gsub("d:","_d").gsub("e:","_e")

    # check the oracle home patches
    all_opatches =  lookupDbVar("oradb_inst_patches#{oracleHome}")
    unless all_opatches == "empty"
      if all_opatches.include? args[1]
        return true
      end
    end

    return patch_exists

  end
end

def lookupDbVar(name)
  #puts "lookup fact "+name
  if dbVarExists(name)
    return lookupvar(name).to_s
  end
  return "empty"
end


def dbVarExists(name)
  #puts "lookup fact "+name
  if lookupvar(name) != :undefined
    if lookupvar(name).nil?
      #puts "return false"
      return false
    end
    return true 
  end
  #puts "not found"
  return false 
end   

