export const money = value => new Intl.NumberFormat('pt-BR',{style:'currency',currency:'BRL'}).format(Number(value)||0);
export const percent = value => `${new Intl.NumberFormat('pt-BR',{minimumFractionDigits:2,maximumFractionDigits:2}).format(Number(value)||0)}%`;
export const dateBR = value => new Intl.DateTimeFormat('pt-BR').format(value ? new Date(value) : new Date());
export const uid = () => crypto.randomUUID();
export const escapeHTML = value => String(value ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
export function calculateViability(v={}) {
  const sale=+v.sale||0, cost=+v.cost||0, shipping=+v.shipping||0, fixed=+v.fixed||0, packaging=+v.packaging||0;
  const rate=+v.rate||0, tax=+v.tax||0, ads=+v.ads||0, loss=+v.loss||0;
  const variable=sale*(rate+tax+ads+loss)/100, total=cost+shipping+fixed+packaging+variable;
  const profit=sale-total, margin=sale ? profit/sale*100 : 0, roi=cost ? profit/cost*100 : 0;
  const variableRate=(rate+tax+ads+loss)/100;
  const breakEven=(cost+shipping+fixed+packaging)/(1-variableRate||1);
  return {sale,cost,total,profit,margin,roi,breakEven,variable};
}
export const viabilityLabel = margin => margin<0?['Inviável','danger']:margin<10?['Risco elevado','warning']:margin<20?['Viável com atenção','attention']:margin<30?['Boa oportunidade','success']:['Excelente margem','success'];

