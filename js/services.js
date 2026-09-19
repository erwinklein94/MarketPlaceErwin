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
export const productService=table('products');
export const supplierService=table('suppliers');
export const salesService=table('sales');
export const analysisService=table('product_viability_analysis');
export const inventoryService=table('inventory_movements');
export const settingsService=table('settings');
export const reportService={exportCSV(rows,filename='relatorio.csv'){const keys=Object.keys(rows[0]||{});const csv=[keys.join(';'),...rows.map(r=>keys.map(k=>`"${String(r[k]??'').replaceAll('"','""')}"`).join(';'))].join('\n');const a=document.createElement('a');a.href=URL.createObjectURL(new Blob(['\ufeff'+csv],{type:'text/csv'}));a.download=filename;a.click();URL.revokeObjectURL(a.href)}};
export { client };
