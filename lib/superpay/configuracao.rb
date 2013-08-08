# -*- encoding : utf-8 -*-
module Superpay

  class Configuracao

    attr_accessor :ambiente, :estabelecimento, :usuario, :senha

    def self.instance
      @__instance__ ||= new
    end

    def teste?
      !producao?
    end

    def producao?
      return Rails.env.production?          if defined?(Rails)
      return (ambiente.to_sym == :producao) if !ambiente.blank?
      return true
    end

  end

end
