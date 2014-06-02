
class Util

	def self.diff_time(start_time, end_time = Time.now)
		diff = (end_time - start_time)
		s = (diff % 60).to_i
		m = (diff / 60).to_i
		h = (m / 60).to_i

		if s > 0
		  "#{(h < 10) ? '0' + h.to_s : h}:#{(m < 10) ? '0' + m.to_s : m}:#{(s < 10) ? '0' + s.to_s : s}"
		else
		  format("%.5f", diff) + " miliseconds."
		end
	end	

end