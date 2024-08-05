{"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface IERC20 {\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract Ownable {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    constructor() {\n        _owner = msg.sender;\n        emit OwnershipTransferred(address(0), _owner);\n    }\n\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    modifier onlyOwner() {\n        require(_owner == msg.sender, \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nlibrary SafeMath {\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a, \"SafeMath: subtraction overflow\");\n        uint256 c = a - b;\n        return c;\n    }\n\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) {\n            return 0;\n        }\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003e 0, \"SafeMath: division by zero\");\n        uint256 c = a / b;\n        return c;\n    }\n}\n"},"WSNPTToken.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./SafeMath.sol\";\nimport \"./IERC20.sol\";\nimport \"./Ownable.sol\";\n\ncontract WSNPTToken is IERC20, Ownable {\n    using SafeMath for uint256;\n\n    string public name = \"Wrapped Snapit World\";\n    string public symbol = \"WSNPT\";\n    uint8 public decimals = 18;\n    uint256 private _totalSupply = 10000000 * 10**uint256(decimals);\n    mapping(address =\u003e uint256) private _balances;\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\n\n    constructor() {\n        _balances[msg.sender] = _totalSupply;\n    }\n\n    function totalSupply() public view override returns (uint256) {\n        return _totalSupply;\n    }\n\n    function balanceOf(address account) public view override returns (uint256) {\n        return _balances[account];\n    }\n\n    function transfer(address recipient, uint256 amount) public override returns (bool) {\n        _transfer(msg.sender, recipient, amount);\n        return true;\n    }\n\n    function allowance(address owner, address spender) public view override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    function approve(address spender, uint256 amount) public override returns (bool) {\n        _approve(msg.sender, spender, amount);\n        return true;\n    }\n\n    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {\n        _transfer(sender, recipient, amount);\n        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));\n        return true;\n    }\n\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\n        return true;\n    }\n\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));\n        return true;\n    }\n\n    function burn(uint256 amount) public onlyOwner returns (bool) {\n        _burn(msg.sender, amount);\n        return true;\n    }\n\n    function _transfer(address sender, address recipient, uint256 amount) internal {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _balances[sender] = _balances[sender].sub(amount);\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(sender, recipient, amount);\n    }\n\n    function _approve(address owner, address spender, uint256 amount) internal {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    function _burn(address account, uint256 amount) internal {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _balances[account] = _balances[account].sub(amount);\n        _totalSupply = _totalSupply.sub(amount);\n        emit Transfer(account, address(0), amount);\n    }\n}\n"}}