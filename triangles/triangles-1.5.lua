-- Given a wedge part t, rescale, position, and orient it so its vertices meet at, bt, ct
-- at, bt, ct must form a right triangle
function RegisterTriangle(t, at, bt, ct)
	local offset = (at + bt) / 2
	t.Size = Vector3.New(Vector3.Distance(at, ct), Vector3.Distance(bt, ct), 0)
	t.Position = offset
	local normal = Vector3.Cross(at - ct, at - bt)
	local planeUp = bt - ct
	t:LookAt(normal + offset, planeUp)
end

-- First two vertices are the longest edge
-- Output remains clockwise
function TriSort(a, b, c)
	local ab = Vector3.Distance(a, b)
	local ac = Vector3.Distance(a, c)
	local bc = Vector3.Distance(b, c)
	if ab > ac and ab > bc then
		return {a, b, c}
	elseif ac > ab and ac > bc then
		return {c, a, b}
	else
		return {b, c, a}
	end
end

-- Given the arbitrary positions a, b, c
-- Find the pair of right triangles which form the triangle
-- And suitably position, scale, and orient t1 and t2 to be that pair
function SplitTriangle(t1, t2, a, b, c)
	local sort = TriSort(a, b, c)
	local a = sort[1]
	local b = sort[2]
	local c = sort[3]
	-- https://math.stackexchange.com/q/436700
	-- https://math.stackexchange.com/a/1426955
	local proportion = Vector3.Dot(a - b, a - c) / (a - b).sqrMagnitude
	local d = proportion * b + (1 - proportion) * a
	RegisterTriangle(t1, c, a, d)
	RegisterTriangle(t2, b, c, d)
end
