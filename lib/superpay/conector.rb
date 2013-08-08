module Superpay
  class Conector

    URL_PRODUCAO     = "https://superpay2.superpay.com.br"
    URL_TESTE        = "http://homologacao2.superpay.com.br"

    TRANSACAO_PATH   = "/superpay/servicosPagamentoCompletoWS.Services?wsdl"
    RECORRENCIA_PATH = "/superpay/servicosRecorrenciaWS.Services?wsdl"

    attr_accessor :savon_client, :savon_client_recorrencia

    def initialize
      self.reload
    end

    def reload
      log_level  = ::Superpay.config.log_level
      log_level  = (::Superpay.config.producao? ? :info : :debug) if log_level.nil?

      parametros = {
        convert_request_keys_to: :lower_camelcase,
        log_level:               log_level,
        pretty_print_xml:        log_level == :debug ? true : false
      }

      @savon_client             = Savon.client(parametros.merge({wsdl: url(TRANSACAO_PATH)}))
      @savon_client_recorrencia = Savon.client(parametros.merge({wsdl: url(RECORRENCIA_PATH)}))
    end

    def self.instance
      @__instance__ ||= new
    end

    def url(servico)
      "#{::Superpay.config.producao? ? URL_PRODUCAO : URL_TESTE}#{servico}"
    end

    def call(metodo, dados, servico=:transacao)
      (servico == :transacao) ? call_transacao(metodo, dados) : call_recorrencia(metodo, dados)
    end

    def call_transacao(metodo, dados)
      parametros = {
        usuario: Configuracao.instance.usuario,
        senha: Configuracao.instance.senha
      }

      @savon_client.call(metodo.to_sym, message: parametros.merge(dados))
    end

    def call_recorrencia(metodo, dados)
      parametros = {
        usuario: {
          usuario: Configuracao.instance.usuario,
          senha: Configuracao.instance.senha
        }
      }

      @savon_client_recorrencia.call(metodo.to_sym, message: parametros.merge(dados))
    end

  end
end
