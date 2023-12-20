select inv.id, inv.created_on , inv.invoice_number , inv.query_string2, po.status, case 
	when po.query_string6 = '2' then 'Dropship'
	when po.query_string6 = 'GESOrgStandardPO' then 'Not Found'
	when po.query_string6 > '2' then 'Other'
	else 'Not Found'
end as POType, dh.message  from xml_invoice inv
left join document_history dh on inv.id = dh.document_id 
left outer join xml_po po on inv.query_string2 = po.po_number 
where inv.sender_id = '23887372201' and inv.receiver_id = '23887372201' 
and inv.created_on::date between '2023-01-01' and current_date 
and dh.message = 'Timed out waiting for PO. Invoice will be assigned to an EDI Reviewer.'
order by created_on asc