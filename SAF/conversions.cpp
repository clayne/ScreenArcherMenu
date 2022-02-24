/***** BEGIN LICENSE BLOCK *****
BSD License
Copyright (c) 2005-2015, NIF File Format Library and Tools
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the NIF File Format Library and Tools project may not be
   used to endorse or promote products derived from this software
   without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
***** END LICENCE BLOCK *****/

//Most of this is from nifskope
//https://github.com/niftools/nifskope/blob/develop/src/data/niftypes.cpp

#include "conversions.h"

#include "f4se/NiObjects.h"

namespace SAF {

	float niMatrix43Identity[12]{ 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f };
	float niTransformIdentity[16]{ 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f };
	float quatIdentity[4]{ 1.0f, 0.0f, 0.0f, 0.0f };

	NiMatrix43 MatrixIdentity() {
		NiMatrix43 m;
		memcpy(m.arr, niMatrix43Identity, sizeof(niMatrix43Identity));
		return m;
	}

	NiTransform TransformIdentity() {
		NiTransform t;
		memcpy(&t, niTransformIdentity, sizeof(niTransformIdentity));
		return t;
	}

	Quat QuaternionIdentity() {
		Quat q;
		memcpy(&q, quatIdentity, sizeof(quatIdentity));
		return q;
	}

	void NiFromEuler(NiMatrix43 &matrix, float x, float y, float z) {
		float sinX = sin(x);
		float cosX = cos(x);
		float sinY = sin(y);
		float cosY = cos(y);
		float sinZ = sin(z);
		float cosZ = cos(z);

		matrix.data[0][0] = cosY * cosZ;
		matrix.data[0][1] = -cosY * sinZ;
		matrix.data[0][2] = sinY;
		matrix.data[1][0] = sinX * sinY * cosZ + sinZ * cosX;
		matrix.data[1][1] = cosX * cosZ - sinX * sinY * sinZ;
		matrix.data[1][2] = -sinX * cosY;
		matrix.data[2][0] = sinX * sinZ - cosX * sinY * cosZ;
		matrix.data[2][1] = cosX * sinY * sinZ + sinX * cosZ;
		matrix.data[2][2] = cosX * cosY;
	}

	void NiToEuler(NiMatrix43 &matrix, float &x, float &y, float &z) {
		if (matrix.data[0][2] < 1.0) {
			if (matrix.data[0][2] > -1.0) {
				x = atan2(-matrix.data[1][2], matrix.data[2][2]);
				y = asin(matrix.data[0][2]);
				z = atan2(-matrix.data[0][1], matrix.data[0][0]);
			}
			else {
				x = -atan2(-matrix.data[1][0], matrix.data[1][1]);
				y = -MATH_PI / 2;
				z = 0.0;
			}
		}
		else {
			x = atan2(matrix.data[1][0], matrix.data[1][1]);
			y = MATH_PI / 2;
			z = 0.0;
		}
	}

	void NiFromDegree(NiMatrix43& matrix, float x, float y, float z) {
		NiFromEuler(matrix, x * -DEGREE_TO_RADIAN, y * -DEGREE_TO_RADIAN, z * -DEGREE_TO_RADIAN);
	}

	void NiToDegree(NiMatrix43& matrix, float& x, float& y, float& z) {
		NiToEuler(matrix, x, y, z);
		x *= -RADIAN_TO_DEGREE;
		y *= -RADIAN_TO_DEGREE;
		z *= -RADIAN_TO_DEGREE;
	}

	NiMatrix43 NiMatrix43Invert(NiMatrix43& matrix) {
		NiMatrix43 i;

		i.data[0][0] = matrix.data[1][1] * matrix.data[2][2] - matrix.data[1][2] * matrix.data[2][1];
		i.data[0][1] = matrix.data[0][2] * matrix.data[2][1] - matrix.data[0][1] * matrix.data[2][2];
		i.data[0][2] = matrix.data[0][1] * matrix.data[1][2] - matrix.data[0][2] * matrix.data[1][1];
		i.data[1][0] = matrix.data[1][2] * matrix.data[2][0] - matrix.data[1][0] * matrix.data[2][2];
		i.data[1][1] = matrix.data[0][0] * matrix.data[2][2] - matrix.data[0][2] * matrix.data[2][0];
		i.data[1][2] = matrix.data[0][2] * matrix.data[1][0] - matrix.data[0][0] * matrix.data[1][2];
		i.data[2][0] = matrix.data[1][0] * matrix.data[2][1] - matrix.data[1][1] * matrix.data[2][0];
		i.data[2][1] = matrix.data[0][1] * matrix.data[2][0] - matrix.data[0][0] * matrix.data[2][1];
		i.data[2][2] = matrix.data[0][0] * matrix.data[1][1] - matrix.data[0][1] * matrix.data[1][0];

		float d = matrix.data[0][0] * i.data[0][0] + matrix.data[0][1] * i.data[1][0] + matrix.data[0][2] * i.data[2][0];

		if (fabs(d) <= 0.0)
			return MatrixIdentity();

		for (int x = 0; x < 3; x++) {
			for (int y = 0; y < 3; y++)
				i.data[x][y] /= d;
		}

		return i;
	}

	NiMatrix43 NiFromQuat(Quat & q)
	{
		float fTx = ((float)2.0) * q[1];
		float fTy = ((float)2.0) * q[2];
		float fTz = ((float)2.0) * q[3];
		float fTwx = fTx * q[0];
		float fTwy = fTy * q[0];
		float fTwz = fTz * q[0];
		float fTxx = fTx * q[1];
		float fTxy = fTy * q[1];
		float fTxz = fTz * q[1];
		float fTyy = fTy * q[2];
		float fTyz = fTz * q[2];
		float fTzz = fTz * q[3];

		NiMatrix43 m;

		m.data[0][0] = (float)1.0 - (fTyy + fTzz);
		m.data[0][1] = fTxy - fTwz;
		m.data[0][2] = fTxz + fTwy;
		m.data[1][0] = fTxy + fTwz;
		m.data[1][1] = (float)1.0 - (fTxx + fTzz);
		m.data[1][2] = fTyz - fTwx;
		m.data[2][0] = fTxz - fTwy;
		m.data[2][1] = fTyz + fTwx;
		m.data[2][2] = (float)1.0 - (fTxx + fTyy);

		return m;
	}

	Quat NiToQuat(NiMatrix43 &m)
	{
		Quat q;

		float trace = m.data[0][0] + m.data[1][1] + m.data[2][2];
		float root;

		if (trace > 0.0) {
			root = sqrt(trace + 1.0);
			q[0] = root / 2.0;
			root = 0.5 / root;
			q[1] = (m.data[2][1] - m.data[1][2]) * root;
			q[2] = (m.data[0][2] - m.data[2][0]) * root;
			q[3] = (m.data[1][0] - m.data[0][1]) * root;
		}
		else {
			int i = (m.data[1][1] > m.data[0][0] ? 1 : 0);

			if (m.data[2][2] > m.data[i][i])
				i = 2;

			const int next[3] = {
				1, 2, 0
			};
			int j = next[i];
			int k = next[j];

			root = sqrt(m.data[i][i] - m.data[j][j] - m.data[k][k] + 1.0);
			q[i + 1] = root / 2;
			root = 0.5 / root;
			q[0] = (m.data[k][j] - m.data[j][k]) * root;
			q[j + 1] = (m.data[j][i] + m.data[i][j]) * root;
			q[k + 1] = (m.data[k][i] + m.data[i][k]) * root;
		}

		return q;
	}

	static inline float ISqrt_approx_in_neighborhood(float s)
	{
		static const float NEIGHBORHOOD = 0.959066f;
		static const float SCALE = 1.000311f;
		static const float ADDITIVE_CONSTANT = SCALE / (float)sqrt(NEIGHBORHOOD);
		static const float FACTOR = SCALE * (-0.5f / (NEIGHBORHOOD * (float)sqrt(NEIGHBORHOOD)));
		return ADDITIVE_CONSTANT + (s - NEIGHBORHOOD) * FACTOR;
	}

	static inline void fast_normalize(Quat& q)
	{
		float s = q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3];
		float k = ISqrt_approx_in_neighborhood(s);

		if (s <= 0.91521198f) {
			k *= ISqrt_approx_in_neighborhood(k * k * s);

			if (s <= 0.65211970f) {
				k *= ISqrt_approx_in_neighborhood(k * k * s);
			}
		}

		q[0] *= k; q[1] *= k; q[2] *= k; q[3] *= k;
	}

	static inline float lerp(float v0, float v1, float perc)
	{
		return v0 + perc * (v1 - v0);
	}

	static inline float correction(float t, float fCos)
	{
		const float s = 0.8228677f;
		const float kc = 0.5855064f;
		float factor = 1.0f - s * fCos;
		float k = kc * factor * factor;
		return t * (k * t * (2.0f * t - 3.0f) + 1.0f + k);
	}

	static float dotproduct(const Quat& q1, const Quat& q2)
	{
		return q1[0] * q2[0] + q1[1] * q2[1] + q1[2] * q2[2] + q1[3] * q2[3];
	}

	Quat SlerpQuat(const Quat& p, const Quat& q, float t)
	{
		// Copyright (c) 2002 Jonathan Blow
		//  "Hacking Quaternions", The Inner Product, March 2002
		//   http://number-none.com/product/Hacking%20Quaternions/index.html

		float tprime;

		if (t <= 0.5f) {
			tprime = correction(t, dotproduct(p, q));
		}
		else {
			tprime = 1.0f - correction(1.0f - t, dotproduct(p, q));
		}

		Quat result(lerp(p[0], q[0], tprime), lerp(p[1], q[1], tprime),
			lerp(p[2], q[2], tprime), lerp(p[3], q[3], tprime));
		fast_normalize(result);
		return result;
	}

	NiTransform SlerpNiTransform(NiTransform& transform, float scalar) {
		NiTransform res;

		res.pos = transform.pos * scalar;
		res.scale = 1.0f + ((transform.scale - 1.0f) * scalar);

		Quat niQuat = NiToQuat(transform.rot);
		Quat slerpedQuat = SlerpQuat(QuaternionIdentity(), niQuat, scalar);

		res.rot = NiFromQuat(slerpedQuat);

		return res;
	}

	NiTransform NegateNiTransform(NiTransform& src, NiTransform& dst) {
		NiTransform res;

		res.pos = dst.pos - src.pos;

		if (src.scale == 0)
			res.scale = 1.0f;
		else
			res.scale = dst.scale / src.scale;

		res.rot = NiMatrix43Invert(src.rot) * dst.rot;

		return res;
	}
}