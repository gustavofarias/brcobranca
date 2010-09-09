# -*- encoding: utf-8 -*-

begin
  require 'rghost'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rghost'
  require 'rghost'
end

begin
  require 'rghost_barcode'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rghost_barcode'
  require 'rghost_barcode'
end

module Brcobranca
  module Boleto
    module Template
      # Templates para usar com Rghost
      module Rghost
        include RGhost unless self.include?(RGhost)

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        def to(formato, options={})
          modelo_generico(formato, options)
        end

        def method_missing(m, *args)
          method = m.to_s
          if method.start_with?("to_")
            modelo_generico(method[3..-1], (args.first || {}))
          else
            super
          end
        end

        # Responsável por setar os valores necessários no template genérico
        # Retorna um stream pronto para gravaçào
        # O tipo do arquivo gerado pode ser modificado incluindo a configuração a baixo dentro da sua aplicação:
        #  Brcobranca::Config::OPCOES[:tipo] = 'pdf'
        # Ou pode ser passado como paramentro:
        #  :formato => 'pdf'
        def modelo_generico(formato, options={})
          doc=Document.new :paper => :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__),'..','..','arquivos','templates','modelo_generico.eps')

          raise "Não foi possível encontrar o template. Verifique o caminho" unless File.exist?(template_path)

          doc.define_template(:template, template_path, :x => '0.3 cm', :y => "0 cm")
          doc.use_template :template

          doc.define_tags do
            tag :grande, :size => 13
          end

          #INICIO Primeira parte do BOLETO
          # LOGOTIPO do BANCO
          doc.image(self.logotipo, :x => '0.5 cm', :y => '23.85 cm', :zoom => 80)
          # Dados
          doc.moveto :x => '5.2 cm' , :y => '23.85 cm'
          doc.show "#{self.banco}-#{self.banco_dv}", :tag => :grande
          doc.moveto :x => '7.5 cm' , :y => '23.85 cm'
          doc.show self.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '0.7 cm' , :y => '23 cm'
          doc.show self.cedente
          doc.moveto :x => '11 cm' , :y => '23 cm'
          doc.show self.agencia_conta_boleto
          doc.moveto :x => '14.2 cm' , :y => '23 cm'
          doc.show self.especie
          doc.moveto :x => '15.7 cm' , :y => '23 cm'
          doc.show self.quantidade
          doc.moveto :x => '0.7 cm' , :y => '22.2 cm'
          doc.show self.numero_documento
          doc.moveto :x => '7 cm' , :y => '22.2 cm'
          doc.show "#{self.documento_cedente.formata_documento}"
          doc.moveto :x => '12 cm' , :y => '22.2 cm'
          doc.show self.data_vencimento.to_s_br
          doc.moveto :x => '16.5 cm' , :y => '23 cm'
          doc.show self.nosso_numero_boleto
          doc.moveto :x => '16.5 cm' , :y => '22.2 cm'
          doc.show self.valor_documento.to_currency
          doc.moveto :x => '1.4 cm' , :y => '20.9 cm'
          doc.show "#{self.sacado} - #{self.sacado_documento.formata_documento}"
          doc.moveto :x => '1.4 cm' , :y => '20.6 cm'
          doc.show "#{self.sacado_endereco}"
          #FIM Primeira parte do BOLETO

          #INICIO Segunda parte do BOLETO BB
          # LOGOTIPO do BANCO
          doc.image(self.logotipo, :x => '0.5 cm', :y => '16.8 cm', :zoom => 80)
          doc.moveto :x => '5.2 cm' , :y => '16.8 cm'
          doc.show "#{self.banco}-#{self.banco_dv}", :tag => :grande
          doc.moveto :x => '7.5 cm' , :y => '16.8 cm'
          doc.show self.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '0.7 cm' , :y => '16 cm'
          doc.show self.local_pagamento
          doc.moveto :x => '16.5 cm' , :y => '16 cm'
          doc.show self.data_vencimento.to_s_br if self.data_vencimento
          doc.moveto :x => '0.7 cm' , :y => '15.2 cm'
          doc.show self.cedente
          doc.moveto :x => '16.5 cm' , :y => '15.2 cm'
          doc.show self.agencia_conta_boleto
          doc.moveto :x => '0.7 cm' , :y => '14.4 cm'
          doc.show self.data_documento.to_s_br if self.data_documento
          doc.moveto :x => '4.2 cm' , :y => '14.4 cm'
          doc.show self.numero_documento
          doc.moveto :x => '10 cm' , :y => '14.4 cm'
          doc.show self.especie
          doc.moveto :x => '11.7 cm' , :y => '14.4 cm'
          doc.show self.aceite
          doc.moveto :x => '13 cm' , :y => '14.4 cm'
          doc.show self.data_processamento.to_s_br if self.data_processamento
          doc.moveto :x => '16.5 cm' , :y => '14.4 cm'
          doc.show self.nosso_numero_boleto
          doc.moveto :x => '4.4 cm' , :y => '13.5 cm'
          doc.show self.carteira
          doc.moveto :x => '6.4 cm' , :y => '13.5 cm'
          doc.show self.moeda
          doc.moveto :x => '8 cm' , :y => '13.5 cm'
          doc.show self.quantidade
          doc.moveto :x => '11 cm' , :y => '13.5 cm'
          doc.show self.valor.to_currency
          doc.moveto :x => '16.5 cm' , :y => '13.5 cm'
          doc.show self.valor_documento.to_currency
          doc.moveto :x => '0.7 cm' , :y => '12.7 cm'
          doc.show @instrucao1
          doc.moveto :x => '0.7 cm' , :y => '12.3 cm'
          doc.show @instrucao2
          doc.moveto :x => '0.7 cm' , :y => '11.9 cm'
          doc.show self.instrucao3
          doc.moveto :x => '0.7 cm' , :y => '11.5 cm'
          doc.show self.instrucao4
          doc.moveto :x => '0.7 cm' , :y => '11.1 cm'
          doc.show self.instrucao5
          doc.moveto :x => '0.7 cm' , :y => '10.7 cm'
          doc.show self.instrucao6
          doc.moveto :x => '1.2 cm' , :y => '8.8 cm'
          doc.show "#{self.sacado} - #{self.sacado_documento.formata_documento}" if self.sacado && self.sacado_documento
          doc.moveto :x => '1.2 cm' , :y => '8.4 cm'
          doc.show "#{self.sacado_endereco}"
          #FIM Segunda parte do BOLETO

          #Gerando codigo de barra com rghost_barcode
          doc.barcode_interleaved2of5(self.codigo_barras, :width => '10.3 cm', :height => '1.3 cm', :x => '0.7 cm', :y => '5.8 cm' ) if self.codigo_barras

          # Gerando stream
          formato ||= Brcobranca.configuration.formato
          resolucao = options.delete(:resolucao) || Brcobranca.configuration.resolucao
          doc.render_stream(formato.to_sym, :resolution => resolucao)
        end
      end
    end
  end
end
