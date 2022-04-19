function y_fit = clifford(x,c,s,m)
%compute Clifford's model function
%x: previous- current
%     theta_ad = np.arcsin((np.sin(x)) / np.sqrt(((s * np.cos(x) - c)) ** 2 +
%                                                (np.sin(x)) ** 2))
%     test = s * np.cos(x) - c < 0
%     theta_ad[test] = np.pi - theta_ad[test]
%     return np.mod(theta_ad - x + np.pi, 2 * np.pi) - np.pi
y_fit = m .* asin((sin(x)) ./ sqrt(((s * cos(x) - c)) .^2 + (sin(x)).^ 2))-x;
end