var ipfsClient = require('ipfs-http-client')
var ipfs = ipfsClient('localhost', '5001', { protocol: 'http' }) // leaving out the arguments will default to these values


// export default ipfs;