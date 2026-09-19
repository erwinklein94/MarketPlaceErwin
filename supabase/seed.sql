-- Execute como o usuário autenticado em um cliente da aplicação.
-- Os dados abaixo são fictícios e as taxas são apenas exemplos editáveis.
insert into public.suppliers(user_id,name,contact,city,state,lead_time_days) values
(auth.uid(),'Atlas Distribuidora','Marina Costa','Campinas','SP',4),
(auth.uid(),'Norte Ferramentas','Rafael Souza','Guarulhos','SP',6);

insert into public.products(user_id,sku,name,category,status,cost_price,sale_price,min_stock,ideal_stock) values
(auth.uid(),'KIT-001','Kit de Ferramentas 108 peças','Ferramentas','Ativo',189.90,349.90,8,30),
(auth.uid(),'MED-204','Medidor Digital Profissional','Medição','Ativo',72.00,149.90,10,35),
(auth.uid(),'ORG-018','Organizador Modular 24 gavetas','Organização','Sem estoque',96.50,189.90,6,20);

insert into public.marketplace_fees(user_id,name,fee_type,value,is_default) values
(auth.uid(),'Tarifa Clássico — VALOR DE EXEMPLO','percent',16,true),
(auth.uid(),'Publicidade — VALOR DE EXEMPLO','percent',3,true);

