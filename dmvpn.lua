--[[
Copyright (c) 2014-2018 Kaarle Ritvanen
Copyright (c) 2015-2017 Timo Teräs
See LICENSE file for license details
]]--

local asn1 = require('asn1')
local rfc3779 = require('asn1.rfc3779')

local base = '1.3.6.1.4.1.31536.1.'

local M = {OID_IS_HUB=base..'1', OID_HUB_HOSTS=base..'2'}

local decoders={
	['sbgp-autonomousSysNum']=function(d)
		local asn = rfc3779.ASIdentifiers.decode(d)
		if asn and asn.asnum and asn.asnum.asIdsOrRanges then
			for _, as in ipairs(asn.asnum.asIdsOrRanges) do
				if as.id then return as.id end
			end
		end
	end,
	['sbgp-ipAddrBlock']=function(d)
		local res = {{}, {}}
		for _, ab in ipairs(rfc3779.IPAddrBlocks.decode(d)) do
			local afi = ab.addressFamily.afi
			if res[afi] and ab.ipAddressChoice and ab.ipAddressChoice.addressesOrRanges then
				for _, a in ipairs(ab.ipAddressChoice.addressesOrRanges) do
					if a.addressPrefix then
						table.insert(res[afi], a.addressPrefix)
					end
				end
			end
		end
		return res
	end,
	[M.OID_IS_HUB]=function(d) return asn1.boolean.decode(d) end,
	[M.OID_HUB_HOSTS]=function(d)
		return asn1.sequence_of(asn1.ia5string).decode(d)
	end
}

function M.decode_ext(oid, ext) return decoders[oid](ext:getData()) end

function M.get_password(new)
	local function get(prompt)
		io.stderr:write(prompt..': ')
		os.execute('stty -echo')
		local res = io.read()
		os.execute('stty echo')
		io.stderr:write('\n')
		return res
	end

	local res = get((new and 'New p' or 'P')..'assword')
	if new and get('Confirm password') ~= res then
		raise('Password mismatch')
	end
	return res
end

return M
