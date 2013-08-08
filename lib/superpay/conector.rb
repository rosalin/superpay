module Superpay
  class Conector

    URL_PRODUCAO     = "https://superpay2.superpay.com.br/checkout"
    URL_TESTE        = "http://homologacao2.superpay.com.br/checkout"

    TRANSACAO_PATH   = "/servicosPagamentoCompletoWS.Services?wsdl"
    RECORRENCIA_PATH = "/servicosRecorrenciaWS.Services?wsdl"

    attr_accessor :savon_client, :savon_client_recorrencia

    def initialize
      self.reload
    end

    def reload
      parametros                = {convert_request_keys_to: :lower_camelcase}

      @savon_client             = Savon.client(parametros.merge({wsdl: url(TRANSACAO_PATH)}))
      @savon_client_recorrencia = Savon.client(parametros.merge({wsdl: url(RECORRENCIA_PATH)}))
    end

    def self.instance
      @__instance__ ||= new
    end

    def url(servico)
      "#{::Superpay.config.producao? ? URL_PRODUCAO : URL_TESTE}#{servico}"
    end

    def call(metodo, transacao, servico=:transacao)
      parametros = {
        usuario: Configuracao.instance.usuario,
        senha: Configuracao.instance.senha
      }

      client = (servico == :transacao) ? @savon_client : @savon_client_recorrencia
      client.call(metodo.to_sym, message: parametros.merge(transacao))
    end

  end
end
