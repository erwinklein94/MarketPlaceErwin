-- Dados inteiramente fictícios para demonstração do ML Gestor.
-- Idempotente: substitui apenas registros com os prefixos DEMO/ML-DEMO.
do $$
declare
  v_user uuid;
  v_supplier uuid;
  v_product uuid;
  v_sale uuid;
  v_name text;
  v_category text;
  v_cost numeric(12,2);
  v_price numeric(12,2);
  v_profit numeric(12,2);
  v_qty int;
  i int;
  names text[] := array[
    'Parafusadeira de Impacto 21V','Kit de Ferramentas 108 peças','Jogo de Chaves Catraca','Alicate Universal Profissional','Furadeira de Impacto 650W','Serra Mármore 1300W','Esmerilhadeira Angular 850W','Trena Laser Digital 40m','Medidor Digital Profissional','Multímetro Digital Automático',
    'Paquímetro Digital 150mm','Nível a Laser 12 Linhas','Balança Digital de Precisão','Termômetro Infravermelho','Organizador Modular 24 gavetas','Caixa Organizadora Empilhável','Estante Multiuso Reforçada','Maleta para Ferramentas 18 pol.','Painel Organizador Perfurado','Gaveteiro Plástico 12 Gavetas',
    'Scanner Automotivo Bluetooth','Compressor de Ar Portátil','Carregador de Bateria 12V','Kit Limpeza Automotiva','Câmera de Ré HD','Suporte Veicular Magnético','Inflador Digital de Pneus','Cabo Auxiliar de Partida','Lanterna LED Recarregável','Mangueira Expansível 15m',
    'Pulverizador Manual 5L','Kit Irrigação por Gotejamento','Luminária Solar de Parede','Fechadura Digital Biométrica','Sensor de Presença Wi-Fi','Câmera Wi-Fi Full HD','Tomada Inteligente Wi-Fi','Hub USB-C 7 em 1','Carregador Rápido 65W','Suporte Articulado para Monitor',
    'Teclado Mecânico Compacto','Mouse Sem Fio Ergonômico','Fone Bluetooth com Microfone','Mochila para Notebook 17 pol.','Bolsa Térmica 20 Litros','Garrafa Térmica Inox 1L','Cinta Ergonômica Lombar','Óculos de Proteção Antiembaçante','Luva Anticorte Nível 5','Protetor Auricular Tipo Concha'
  ];
  categories text[] := array['Ferramentas','Ferramentas','Ferramentas','Ferramentas','Ferramentas','Ferramentas','Ferramentas','Medição','Medição','Medição','Medição','Medição','Medição','Medição','Organização','Organização','Organização','Organização','Organização','Organização','Automotivo','Automotivo','Automotivo','Automotivo','Automotivo','Automotivo','Automotivo','Automotivo','Casa e Jardim','Casa e Jardim','Casa e Jardim','Casa e Jardim','Casa e Jardim','Casa e Jardim','Eletrônicos','Eletrônicos','Eletrônicos','Eletrônicos','Eletrônicos','Eletrônicos','Eletrônicos','Eletrônicos','Eletrônicos','Acessórios','Acessórios','Acessórios','Segurança','Segurança','Segurança','Segurança'];
begin
  select id into v_user from auth.users where email='erwinklein1994@gmail.com' limit 1;
  if v_user is null then raise exception 'Crie primeiro o usuário autorizado no Supabase Auth'; end if;

  delete from public.sales where user_id=v_user and order_number like 'ML-DEMO-%';
  delete from public.products where user_id=v_user and sku like 'DEMO-%';
  delete from public.suppliers where user_id=v_user and name in ('Atlas Distribuidora','Norte Ferramentas','Vetor Imports','Orbital Atacado','Ponto Smart Distribuição');

  insert into public.suppliers(user_id,name,contact,city,state,lead_time_days,notes) values
    (v_user,'Atlas Distribuidora','Marina Costa','Campinas','SP',4,'FORNECEDOR FICTÍCIO'),
    (v_user,'Norte Ferramentas','Rafael Souza','Guarulhos','SP',6,'FORNECEDOR FICTÍCIO'),
    (v_user,'Vetor Imports','Bianca Lima','Curitiba','PR',9,'FORNECEDOR FICTÍCIO'),
    (v_user,'Orbital Atacado','Lucas Mendes','Joinville','SC',7,'FORNECEDOR FICTÍCIO'),
    (v_user,'Ponto Smart Distribuição','Aline Rocha','São Paulo','SP',3,'FORNECEDOR FICTÍCIO');

  for i in 1..50 loop
    v_name := names[i]; v_category := categories[i];
    v_cost := round((35 + mod(i*17,180) + mod(i,3)*0.9)::numeric,2);
    v_price := round((v_cost * (1.72 + mod(i,5)*0.06))::numeric,2);
    v_profit := round((v_price - v_cost - v_price*0.24 - 9)::numeric,2);
    select id into v_supplier from public.suppliers where user_id=v_user order by name offset mod(i-1,5) limit 1;
    insert into public.products(user_id,supplier_id,sku,name,category,status,cost_price,sale_price,total_cost,expected_profit,net_margin,roi,min_stock,ideal_stock,notes)
    values(v_user,v_supplier,'DEMO-'||lpad(i::text,3,'0'),v_name,v_category,case when mod(i,13)=0 then 'Sem estoque' when mod(i,11)=0 then 'Em teste' else 'Ativo' end,v_cost,v_price,round((v_price-v_profit)::numeric,2),v_profit,round((v_profit/nullif(v_price,0)*100)::numeric,4),round((v_profit/nullif(v_cost,0)*100)::numeric,4),8+mod(i,6),30+mod(i*3,35),'PRODUTO FICTÍCIO DE DEMONSTRAÇÃO') returning id into v_product;
    insert into public.inventory(user_id,product_id,quantity,min_stock,ideal_stock,last_entry_at) values(v_user,v_product,case when mod(i,13)=0 then 0 else 5+mod(i*7,43) end,8+mod(i,6),30+mod(i*3,35),now()-make_interval(days=>mod(i,20)));
  end loop;

  for i in 1..120 loop
    select id,cost_price,sale_price,name into v_product,v_cost,v_price,v_name from public.products where user_id=v_user and sku like 'DEMO-%' order by sku offset mod(i*7,50) limit 1;
    v_qty := 1+mod(i,4); v_profit := round(((v_price-v_cost-v_price*0.24-9)*v_qty)::numeric,2);
    insert into public.sales(user_id,order_number,sale_date,status,gross_revenue,cost_of_goods,marketplace_fee,fixed_fee,gross_profit,net_profit,net_margin,notes)
    values(v_user,'ML-DEMO-'||lpad((1000+i)::text,5,'0'),now()-make_interval(days=>mod(i,75),hours=>mod(i,8)),case when mod(i,31)=0 then 'Devolvida' when mod(i,23)=0 then 'Cancelada' else 'Concluída' end,v_price*v_qty,v_cost*v_qty,v_price*v_qty*0.24,9*v_qty,(v_price-v_cost)*v_qty,v_profit,round((v_profit/nullif(v_price*v_qty,0)*100)::numeric,4),'VENDA FICTÍCIA DE DEMONSTRAÇÃO') returning id into v_sale;
    insert into public.sale_items(user_id,sale_id,product_id,quantity,unit_price,unit_cost,line_total) values(v_user,v_sale,v_product,v_qty,v_price,v_cost,v_price*v_qty);
  end loop;

  insert into public.settings(user_id,preferences) values(v_user,jsonb_build_object('monthlyProfitTarget',7000,'noSalesAlertDays',30)) on conflict(user_id) do nothing;
end $$;
