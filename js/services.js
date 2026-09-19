import { SUPABASE_URL, SUPABASE_ANON_KEY } from './config.js';
const client = window.supabase?.createClient(SUPABASE_URL,SUPABASE_ANON_KEY);
export const authService = {
  session: async()=> (await client.auth.getSession()).data.session,
  login: async(email,password)=>client.auth.signInWithPassword({email,password}),
  logout: async()=>client.auth.signOut(),
  onChange: callback=>client.auth.onAuthStateChange((_event,session)=>callback(session))
};
const table = name => ({
  list: async(order='created_at')=>{const {data,error}=await client.from(name).select('*').order(order,{ascending:false});if(error)throw error;return data},
  save: async(record)=>{const {data,error}=await client.from(name).upsert(record).select().single();if(error)throw error;return data},
  remove: async(id)=>{const {error}=await client.from(name).delete().eq('id',id);if(error)throw error}
});
const productTable=table('products');
export const productService={...productTable,list:async()=>{const {data,error}=await client.from('products').select('*, inventory(quantity,min_stock,ideal_stock)').order('created_at',{ascending:false});if(error)throw error;return data.map(p=>{const inv=Array.isArray(p.inventory)?p.inventory[0]:p.inventory;return{...p,stock:inv?.quantity??0,min_stock:inv?.min_stock??p.min_stock,ideal_stock:inv?.ideal_stock??p.ideal_stock,margin:+p.net_margin||0,profit:+p.expected_profit||0}})}};
export const supplierService=table('suppliers');
const salesTable=table('sales');
export const salesService={...salesTable,list:async()=>{const {data,error}=await client.from('sales').select('*, sale_items(quantity, product:products(name))').order('sale_date',{ascending:false});if(error)throw error;return data.map(s=>({...s,created_at:s.sale_date,total:+s.gross_revenue||0,quantity:(s.sale_items||[]).reduce((a,i)=>a+i.quantity,0),product:(s.sale_items||[]).map(i=>i.product?.name).filter(Boolean).join(', ')||'Venda'}))}};
export const analysisService=table('product_viability_analysis');
export const inventoryService=table('inventory_movements');
export const settingsService={
  get:async()=>{const {data,error}=await client.from('settings').select('preferences').maybeSingle();if(error)throw error;return data?.preferences||{}},
  save:async preferences=>{const {data:{user},error:userError}=await client.auth.getUser();if(userError||!user)throw userError||new Error('Sessão expirada');const {data,error}=await client.from('settings').upsert({user_id:user.id,preferences},{onConflict:'user_id'}).select('preferences').single();if(error)throw error;return data.preferences}
};
export const reportService={exportCSV(rows,filename='relatorio.csv'){const keys=Object.keys(rows[0]||{});const csv=[keys.join(';'),...rows.map(r=>keys.map(k=>`"${String(r[k]??'').replaceAll('"','""')}"`).join(';'))].join('\n');const a=document.createElement('a');a.href=URL.createObjectURL(new Blob(['\ufeff'+csv],{type:'text/csv'}));a.download=filename;a.click();URL.revokeObjectURL(a.href)}};
export { client };
