# ML Gestor

Sistema web privado para gestão de viabilidade, produtos, estoque, vendas e rentabilidade de uma pequena operação de marketplace. A interface foi inspirada na composição limpa e operacional da referência enviada: sidebar arredondada, painéis densos, cartões financeiros e acentos de cor claros.

## Funcionalidades

- Autenticação por e-mail e senha com Supabase Auth, sem cadastro público na interface.
- Dashboard executivo, catálogo, análise de viabilidade em tempo real, simulação, estoque, vendas, fornecedores, taxas, relatórios e configurações.
- Cálculo centralizado de lucro, margem, ROI e preço de equilíbrio.
- Exportação CSV, backup JSON e validação de importação.
- Layout responsivo, formatação pt-BR e modo de demonstração local.
- Banco com UUIDs, relacionamentos, histórico de preços/custos, auditoria e RLS para o usuário autorizado.

## Estrutura

```text
index.html
css/styles.css
js/
  app.js             # interface, rotas e fluxos
  services.js        # acesso centralizado ao Supabase
  utils.js           # cálculos e formatação
  demo-data.js       # dados fictícios da demonstração
  config.example.js  # modelo de configuração versionado
supabase/
  schema.sql          # tabelas, índices, triggers, RLS e grants
  seed.sql            # dados fictícios opcionais
```

## Configuração do Supabase

1. No painel do Supabase, abra **SQL Editor** e execute `supabase/schema.sql`.
2. Em **Authentication → Users**, crie manualmente o usuário `erwinklein1994@gmail.com` e defina uma senha segura. Não habilite cadastro público no app.
3. O arquivo `js/config.js` já aponta para o projeto autorizado e contém somente a chave **publishable** pública. Para outro projeto, copie `js/config.example.js` sobre ele e troque os valores.
4. A publishable/anon key identifica o projeto, mas não é uma senha; a proteção real está no Auth e nas políticas RLS. Nunca use `service_role` no navegador.
5. Para dados fictícios, autentique-se no app e insira os exemplos, ou adapte `supabase/seed.sql` para uma sessão autenticada. Nenhuma senha é incluída no seed.

O schema restringe cada linha a `auth.uid() = user_id` e também exige que o e-mail verificado no JWT seja `erwinklein1994@gmail.com`. Usuários autenticados com outro e-mail não acessam os dados.

## Executar localmente

Sirva a pasta por HTTP; módulos ES não funcionam de modo confiável abrindo o arquivo diretamente:

```bash
python -m http.server 8080
```

Acesse `http://localhost:8080`. Para visualizar a interface com dados fictícios sem autenticação, use apenas em desenvolvimento: `http://localhost:8080/?demo=1`.

## Publicar no GitHub Pages

1. Envie o projeto ao repositório GitHub.
2. Em **Settings → Pages**, selecione **Deploy from a branch**.
3. Escolha `main` e a pasta `/ (root)`.
4. Em Supabase, configure **Authentication → URL Configuration** com a URL publicada como Site URL e Redirect URL.

O `js/config.js` publicado contém apenas a URL e a chave publishable, necessárias para um frontend estático. Essas informações não concedem acesso por si só: RLS e Auth continuam obrigatórios.

## Segurança

- Não há senha, chave `service_role` ou segredo no repositório.
- RLS está habilitado em todas as tabelas expostas.
- A aplicação não confia apenas na interface para autorização.
- Taxas de marketplace são parâmetros configuráveis; números de demonstração não representam taxas atuais.
