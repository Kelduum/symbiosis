# symbiosis/domains.rb
#
# This code is released under the same terms as Ruby itself.  See LICENCE for
# more details.
#
# (c) 2010 Bytemark Computer Consulting Ltd
#

require 'symbiosis/domain'

module Symbiosis

  #
  # A class for working with domains
  #
  class Domains

    #
    # Find all domains, and iterate over each one.
    #
    def self.each(prefix="/srv",&block)
      all(prefix).each(&block)
    end

    #
    # Does the specified domain exist on this system?
    #
    def self.include?(domain, prefix="/srv")
      all(prefix).find(domain).is_a?(Domain)
    end

    #
    # Finds a domain.  Returns either a Domain, or nil if nothing was found.
    #
    def self.find(domain, prefix="/srv")
      #
      # make capital letters lower-case.
      #
      domain = domain.to_s.downcase

      #
      # Sanity check name.
      #
      return nil unless domain =~ /^[a-z0-9-]+\.([a-z0-9-]+\.?)+$/
     
      #
      # Search all domains.  This returns a maximum of two results -- one with
      # www. and one without, assuming /srv/www.domain and /srv/domain both
      # exist.
      #
      possibles = all(prefix).select{|d| domain =~ /^(www\.)?#{d.name}$/}

      #
      # Nothing found, return nil
      #
      return nil if possibles.length == 0      

      #
      # Return the one and only result.
      #
      return possibles.first if possibles.length == 1

      #
      # Return the domain with the exact-matching name
      #
      return possibles.find{|d| d.name == domain}
    end

    #
    # Find all domains in prefix.  Returns an array of Symbiosis::Domain
    #
    def self.all(prefix = "/srv")
      results = Array.new

      #
      #  For each domain.
      #
      Dir.glob( File.join(prefix,"*") ) do |entry|
        #
        # Only interested in directories
        #
        next unless File.directory?(entry)

        this_prefix, domain = File.split(entry)
        #
        # Don't want dotfiles.
        #
        next if domain =~ /^\./ 

        begin
          results << Domain.new(domain, this_prefix)
        rescue ArgumentError => err
          warn err.to_s
        end
      end

      results
    end

  end
end
