# Cryptographically signed tags on Github

To implement cryptographically signed tags, you will need to generate a GPG (GNU Privacy Guard) key, tell Git to use it for signing and then upload the public key to GitHub so it can verify your identity.

## Generate a GPG Key

If you don't have one yet, open your terminal and run:

```Bash
gpg2 --full-generate-key
```

- choose a keysize of 4096;
- enter your name and the email address associated with your GitHub account;
- set a strong passphrase.

## Tell Git about the key

First, find your key ID:

```Bash
gpg2 --list-secret-keys --keyid-format=LONG
```

Look for the line starting with `sec`. The ID is the hex code after the slash (e.g. `ABC1234567890DEF`). Copy it and run:

```Bash
git config user.signingkey ABC1234567890DEF
```

## Add the key to GitHub

- Export your public key: `gpg2 --armor --export ABC1234567890DEF`;
- copy the output (including the `BEGIN` and `END` lines);
- go to `GitHub Settings > SSH and GPG keys > New GPG Key`;
- paste the key and save.

## Create a signed tag

When you are ready to release a version (e.g., `v1.2.3`), use the `-s` flag instead of just `-a`:

```Bash
git tag -s v1.2.3 -m "Release version 1.2.3 with security fixes"
git push origin v1.2.3
```

## How it looks on GitHub

Once pushed, GitHub will display a "Verified" badge next to the tag in the "Releases" or "Tags" section of your repository. This proves that the tag was created by you and hasn't been tampered with.

## Global signing

If you want Git to sign every commit and tag by default so you don't have to remember the flags, run:

```Bash
git config commit.gpgsign true
git config tag.gpgsign true
```
