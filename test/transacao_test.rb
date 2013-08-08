# -*- encoding : utf-8 -*-
require 'minitest/autorun'
require 'superpay'

describe Superpay::Transacao do

  before do
    Superpay.config do |config|
      config.ambiente         = :teste
      config.estabelecimento  = 1369338339932
      config.usuario          = 'ERNET'
      config.senha            = 'ERNET'
    end

    # Cliente
    @usuario_transacao = {
      codigo_cliente: 1,
      tipo_cliente: 1,
      nome_comprador: 'Marcelo',
      documento_comprador: '04795729921',
      documento2_comprador: '97619077',
      sexo_comprador: 'M',
      data_nascimento_comprador: Time.new(1981, 07, 11),
      telefone_comprador: '34166404',
      ddd_comprador: '16',
      ddi_comprador: '55',
      codigo_tipo_telefone_comprador: 1,
      telefone_adicional_comprador: '34166405',
      ddd_adicional_comprador: '16',
      ddi_adicional_comprador: '55',
      codigo_tipo_telefone_adicional_comprador: 1,
      email_comprador: 'marcelo@qw3.com.br',
      endereco_comprador: 'Giácomo Casale',
      numero_endereco_comprador: '147',
      bairro_endereco_comprador: 'Jardim Alvorada',
      complemento_endereco_comprador: '',
      cidade_endereco_comprador: 'São Carlos',
      estado_endereco_comprador: 'SP',
      cep_endereco_comprador: '13562350',
      endereco_entrega: 'Giácomo Casale',
      numero_endereco_entrega: '147',
      bairro_endereco_entrega: 'Jardim Alvorada',
      complemento_endereco_entrega: '',
      cidade_endereco_entrega: 'São Carlos',
      estado_endereco_entrega: 'SP',
      cep_endereco_entrega: '13562350',
      telefone_entrega: '34166404',
      ddd_entrega: '16',
      ddi_entrega: '55',
      codigo_tipo_telefone_entrega: 1,
      telefone_adicional_entrega: '34166404',
      ddd_adicional_entrega: '16',
      ddi_adicional_entrega: '55',
      codigo_tipo_telefone_adicional_entrega: 1,
    }

    # Pedido
    @itens_do_pedido = [
      {
        codigo_produto: 1,
        codigo_categoria: 1,
        nome_produto: 'Produto 1',
        nome_categoria: 'Categoria 1',
        quantidade_produto: 1,
        valor_unitario_produto: 50
      },
      {
        codigo_produto: 1,
        codigo_categoria: 1,
        nome_produto: 'Produto 1',
        nome_categoria: 'Categoria 1',
        quantidade_produto: 1,
        valor_unitario_produto: 50
      }
    ]

    # Dados da venda
    @venda = {
      numero_transacao: 104,
      codigo_forma_pagamento: 120,
      valor: 100,
      valor_desconto: 0,
      taxa_embarque: 0,
      parcelas: 1,
      nome_titular_cartao_credito: 'Marcelo',
      numero_cartao_credito: '4444333322221111',
      codigo_seguranca: '123',
      data_validade_cartao: '12/2016',
      url_campainha: 'teste',
      "IP" => '187.39.185.39',
      idioma: 1,
      origem_transacao: 1,
      campo_livre1: '',
      campo_livre2: '',
      campo_livre3: '',
      campo_livre4: '',
      campo_livre5: '',
      dados_usuario_transacao: @usuario_transacao,
      itens_do_pedido: @itens_do_pedido
    }

    @recorrencia = {
      numero_recorrencia:      Time.now.to_i,
      valor:                   19.90,
      forma_pagamento:         121,
      quantidade_cobrancas:    0,
      dia_cobranca:            Time.now.strftime("%d"),
      periodicidade:           3,
      primeira_cobranca:       1,
      processar_imediatamente: 1,
      url_notificacao:         "http://google.com/superpay",

      dados_cartao: {
        nome_portador: "user test",
        numero_cartao: "5390124620377429",
        codigo_seguranca: "123",
        data_validade: "12/2016"
      },

      dados_cobranca: {
        nome_comprador: "casal 20",
        email_comprador: "teste@teste.com.br",
        telefone: [{
          ddi: "55", ddd: "51", telefone: "12341234", tipo_telefone: 1
        }]
      }
    }

  end

  it "deveria gerenciar uma recorrencia com sucesso" do
    retorno = Superpay::Transacao.cadastrar_recorrencia(@recorrencia)
    retorno[:status].must_equal true

    retorno = Superpay::Transacao.consultar_recorrencia(@recorrencia[:numero_recorrencia])
    retorno[:valor].must_equal 19.90

    retorno = Superpay::Transacao.cancelar_recorrencia(@recorrencia[:numero_recorrencia])
    retorno[:status].must_equal false
  end


  it "deveria pagar com sucesso" do
    transacao = Superpay::Transacao.pagar(@venda)
    transacao[:autorizacao].must_equal '0'
    transacao[:codigo_estabelecimento].must_equal Superpay.config.estabelecimento.to_s
    transacao[:codigo_forma_pagamento].must_equal '120'
    transacao[:codigo_transacao_operadora].must_equal '0'
    transacao[:numero_transacao].must_equal '104'
    transacao[:parcelas].must_equal '1'
    transacao[:status_transacao].must_equal '31'
    transacao[:status].must_equal :ja_efetuada
    transacao[:taxa_embarque].must_equal 0
    transacao[:valor].must_equal 1
    transacao[:valor_desconto].must_equal 0
    # transacao[:data_aprovacao_operadora].must_equal '21/06/2013'
    # transacao[:mensagem_venda].must_equal 'Autorizada'
  end

  it "deveria consultar com sucesso" do
    transacao = Superpay::Transacao.consultar(104)
    transacao[:autorizacao].must_equal '0'
    transacao[:codigo_estabelecimento].must_equal Superpay.config.estabelecimento.to_s
    transacao[:codigo_forma_pagamento].must_equal '120'
    transacao[:codigo_transacao_operadora].must_equal '0'
    transacao[:numero_transacao].must_equal '104'
    transacao[:parcelas].must_equal '1'
    transacao[:status_transacao].must_equal '13'
    transacao[:status].must_equal :cancelada
    transacao[:valor].must_equal 1
    transacao[:taxa_embarque].must_equal 0
    transacao[:valor_desconto].must_equal 0
    # transacao[:data_aprovacao_operadora].must_equal '21/06/2013'
    # transacao[:mensagem_venda].must_equal 'Autorizada'
  end

  # it "deveria voltar erro se consultar transacao que não existe" do
  #   transacao = Superpay::Transacao.consultar(0)
  #   puts transacao.to_yaml
  # end

  it "deveria pagar pela primeira vez com sucesso" do
    transacao = {
      numero_transacao: 106,
      codigo_forma_pagamento: 121,
      valor: 107.45,
      valor_desconto: 0,
      taxa_embarque: 0,
      parcelas: 1,
      nome_titular_cartao_credito: 'Marcelo',
      numero_cartao_credito: '5390124620377429',
      codigo_seguranca: '123',
      data_validade_cartao: '12/2016',
      url_campainha: 'teste',
      "IP" => '187.39.185.39',
      idioma: 1,
      origem_transacao: 1,
      campo_livre1: '',
      campo_livre2: '',
      campo_livre3: '',
      campo_livre4: '',
      campo_livre5: '',
      dados_usuario_transacao: {
        codigo_cliente: 1,
        tipo_cliente: 1,
        nome_comprador: 'Marcelo',
        documento_comprador: '04795729921',
        documento2_comprador: '97619077',
        sexo_comprador: 'M',
        data_nascimento_comprador: Time.new(1981, 07, 11),
        telefone_comprador: '34166404',
        ddd_comprador: '16',
        ddi_comprador: '55',
        codigo_tipo_telefone_comprador: 1,
        telefone_adicional_comprador: '34166405',
        ddd_adicional_comprador: '16',
        ddi_adicional_comprador: '55',
        codigo_tipo_telefone_adicional_comprador: 1,
        email_comprador: 'marcelo@qw3.com.br',
        endereco_comprador: 'Giácomo Casale',
        numero_endereco_comprador: '147',
        bairro_endereco_comprador: 'Jardim Alvorada',
        complemento_endereco_comprador: '',
        cidade_endereco_comprador: 'São Carlos',
        estado_endereco_comprador: 'SP',
        cep_endereco_comprador: '13562350',
        endereco_entrega: 'Giácomo Casale',
        numero_endereco_entrega: '147',
        bairro_endereco_entrega: 'Jardim Alvorada',
        complemento_endereco_entrega: '',
        cidade_endereco_entrega: 'São Carlos',
        estado_endereco_entrega: 'SP',
        cep_endereco_entrega: '13562350',
        telefone_entrega: '34166404',
        ddd_entrega: '16',
        ddi_entrega: '55',
        codigo_tipo_telefone_entrega: 1,
        telefone_adicional_entrega: '34166404',
        ddd_adicional_entrega: '16',
        ddi_adicional_entrega: '55',
        codigo_tipo_telefone_adicional_entrega: 1
      },
      itens_do_pedido: {
        codigo_produto: 1,
        codigo_categoria: 1,
        nome_produto: 'Produto 1',
        nome_categoria: 'Categoria 1',
        quantidade_produto: 1,
        valor_unitario_produto: 107.45
      }
    }

    transacao = Superpay::Transacao.pagar( transacao )
    transacao[:autorizacao].must_equal '0'
    transacao[:codigo_estabelecimento].must_equal Superpay.config.estabelecimento.to_s
    transacao[:codigo_forma_pagamento].must_equal '121'
    transacao[:codigo_transacao_operadora].must_equal '0'
    transacao[:numero_transacao].must_equal '106'
    transacao[:parcelas].must_equal '1'
    transacao[:status_transacao].must_equal '31'
    transacao[:status].must_equal :ja_efetuada
    transacao[:taxa_embarque].must_equal 0
    transacao[:valor].must_equal 107.45
    transacao[:valor_desconto].must_equal 0

    # transacao[:data_aprovacao_operadora].must_equal Date.today
    # transacao[:mensagem_venda].must_equal 'Autorizada'
  end
end
